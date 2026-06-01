{
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}:
let
  cfg = config.custom.paperclip;
  user = "paperclip";
  paperclipSystemConfig = systemConfig // {
    inherit user;
  };
  paperclipai = pkgs.buildNpmPackage {
    pname = "paperclipai";
    version = "2026.512.0";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/paperclipai/-/paperclipai-2026.512.0.tgz";
      hash = "sha256-XnTgfWyIQJfjiyzl/vRvSgghtA1mDy+c01XpuPqFv1U=";
    };
    npmDepsHash = "sha256-9gq126fy9TvMWVYVzluBcbXVVZa50HaGVBwuVFD+j6U=";
    npmFlags = [ "--legacy-peer-deps" ];
    dontNpmBuild = true;
    postPatch = ''
      cp ${./paperclipai-package-lock.json} package-lock.json
    '';
  };
in
with lib;
{
  options.custom.paperclip = {
    enable = mkEnableOption "Paperclip";

    git = mkOption {
      default = { };
      type = types.submodule {
        options = {
          userName = mkOption {
            type = types.str;
            description = "Git user name for the Paperclip service user.";
          };

          email = mkOption {
            type = types.str;
            description = "Git email for the Paperclip service user.";
          };

          githubAppAuth = mkOption {
            default = { };
            type = types.submodule {
              options = {
                environmentFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to an environment file containing GITHUB_APP_ID and GITHUB_APP_INSTALLATION_ID.";
                };

                privateKeyFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to the GitHub App private key file.";
                };
              };
            };
          };
        };
      };
    };

    context7 = mkOption {
      default = { };
      type = types.submodule {
        options = {
          environmentFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to an environment file containing CONTEXT7_API_KEY.";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (import ../../shared/home-manager {
      inherit pkgs;
      systemConfig = paperclipSystemConfig;
    })

    {
      assertions = [
        {
          assertion = config.virtualisation.docker.enable;
          message = "services.paperclip requires virtualisation.docker.enable = true;";
        }
        {
          assertion = config.virtualisation.oci-containers.backend == "docker";
          message = "services.paperclip requires virtualisation.oci-containers.backend = \"docker\";";
        }
        {
          assertion = cfg.git.githubAppAuth.environmentFile != null;
          message = "custom.paperclip.git.githubAppAuth.environmentFile must be set when custom.paperclip.enable is true.";
        }
        {
          assertion = cfg.git.githubAppAuth.privateKeyFile != null;
          message = "custom.paperclip.git.githubAppAuth.privateKeyFile must be set when custom.paperclip.enable is true.";
        }
        {
          assertion = cfg.context7.environmentFile != null;
          message = "custom.paperclip.context7.environmentFile must be set when custom.paperclip.enable is true.";
        }
      ];

      users.users.${user} = {
        isSystemUser = true;
        group = "${user}";
        extraGroups = [ "docker" ];
        description = "PaperclipAI service user";
        home = "/home/${user}";
        createHome = true;
        shell = pkgs.zsh;
      };
      users.groups.${user} = { };

      home-manager.users.${user} =
        {
          ...
        }:
        {
          home = {
            packages = [ ];
            sessionVariables = {
              GITHUB_APP_PRIVATE_KEY_FILE = cfg.git.githubAppAuth.privateKeyFile;
            };
          };

          programs.zsh.initContent = mkOrder 900 ''
            for file in ${
              escapeShellArgs [
                cfg.git.githubAppAuth.environmentFile
                cfg.context7.environmentFile
              ]
            }; do
              if [[ -r "$file" ]]; then
                set -a
                source "$file"
                set +a
              fi
            done
          '';

          custom.golang.enable = true;
          custom.python.enable = true;

          custom.coding-agent = {
            enable = true;
            agents = {
              claude-code.enable = true;
              codex.enable = true;
            };

            skills.enable = [
              "brainstorming"
              "dispatching-parallel-agents"
              "executing-plans"
              "finishing-a-development-branch"
              "receiving-code-review"
              "requesting-code-review"
              "subagent-driven-development"
              "systematic-debugging"
              "test-driven-development"
              "using-git-worktrees"
              "using-superpowers"
              "verification-before-completion"
              "writing-plans"
              "frontend-design"
              "find-docs"
              "feature-branch"
              "golang-pro"
              "atlas"
            ];
          };

          custom.git = {
            enable = true;
            userName = cfg.git.userName;
            email = cfg.git.email;
            gh.githubAppAuth.enable = true;
          };
        };

      networking.firewall.allowedTCPPorts = [ 3100 ];

      systemd.services.paperclipai = {
        description = "PaperclipAI";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "home-manager-paperclip.service"
        ];
        wants = [ "home-manager-paperclip.service" ];
        path = [
          "/etc/profiles/per-user/${user}"
          "/run/current-system/sw"
        ];
        serviceConfig = {
          ExecStart = "${paperclipai}/bin/paperclipai run";
          StateDirectory = "paperclipai";
          EnvironmentFile = [
            cfg.git.githubAppAuth.environmentFile
            cfg.context7.environmentFile
          ];
          Environment = [
            "HOME=/home/${user}"
            "GITHUB_APP_PRIVATE_KEY_FILE=${cfg.git.githubAppAuth.privateKeyFile}"
          ];
          User = "${user}";
          Group = "${user}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    }
  ]);
}
