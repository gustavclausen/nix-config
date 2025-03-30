{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.git;
in
  with lib; {
    options.custom.git = {
      enable = mkEnableOption "Git config";

      userName = mkOption {
        description = "Username of local Git user";
        type = types.str;
      };

      email = mkOption {
        description = "Email of local Git user";
        type = types.str;
      };

      sshAuth = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "Enable SSH authentication";
            hostnames = mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
              description = "Hostnames of Git servers (e.g. github.com)";
            };
            publicKey = mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Public SSH key";
            };
            privateKeyPath = mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Path to private SSH key";
            };
          };
        };
      };

      gpgCommitSigning = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "Enable GPG commit signing";
            keyId = mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "PGP signing key ID";
            };
            publicKey = mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Public PGP key";
            };
            privateKeyPath = mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Path to private PGP key";
            };
          };
        };
      };
    };

    config = let
      sshHome = "${config.home.homeDirectory}/.ssh";

      sshPublicKeyPath = "${sshHome}/id_git.pub";
      sshPrivateKeyPath = "${sshHome}/id_git";
      gpgPublicKeyPath = "${sshHome}/pgp_git.pub";
      gpgPrivateKeyPath = "${sshHome}/pgp_git.key";
    in
      mkIf cfg.enable {
        assertions = lib.mkMerge [
          (
            lib.mkIf cfg.gpgCommitSigning.enable [
              {
                assertion = cfg.gpgCommitSigning.keyId != null;
                message = "custom.git.gpgCommitSigning.keyId must be set when GPG commit signing is enabled.";
              }
              {
                assertion = cfg.gpgCommitSigning.publicKey != null;
                message = "custom.git.gpgCommitSigning.publicKey must be set when GPG commit signing is enabled.";
              }
              {
                assertion = cfg.gpgCommitSigning.privateKeyPath != null;
                message = "custom.git.gpgCommitSigning.privateKeyPath must be set when GPG commit signing is enabled.";
              }
            ]
          )
          (
            lib.mkIf cfg.sshAuth.enable [
              {
                assertion = cfg.sshAuth.publicKey != null;
                message = "custom.git.sshAuth.publicKey must be set when SSH authentication is enabled.";
              }
              {
                assertion = cfg.sshAuth.privateKeyPath != null;
                message = "custom.git.sshAuth.privateKeyPath must be set when SSH authentication is enabled.";
              }
              {
                assertion = cfg.sshAuth.hostnames != null && (builtins.length cfg.sshAuth.hostnames > 0);
                message = "custom.git.sshAuth.hostnames must be set and must contain at least one hostname when SSH authentication is enabled.";
              }
            ]
          )
        ];

        home = {
          packages = with pkgs;
            lib.mkMerge [
              [git]
              (lib.mkIf cfg.gpgCommitSigning.enable [gnupg (lib.mkIf pkgs.stdenv.isDarwin pinentry_mac)])
            ];

          file = {
            "${sshPublicKeyPath}" = lib.mkIf cfg.sshAuth.enable {
              text = cfg.sshAuth.publicKey;
            };

            "${sshPrivateKeyPath}" = lib.mkIf cfg.sshAuth.enable {
              source = config.lib.file.mkOutOfStoreSymlink cfg.sshAuth.privateKeyPath;
            };

            "${gpgPublicKeyPath}" = lib.mkIf cfg.gpgCommitSigning.enable {
              text = cfg.gpgCommitSigning.publicKey;
            };

            "${gpgPrivateKeyPath}" = lib.mkIf cfg.gpgCommitSigning.enable {
              source = config.lib.file.mkOutOfStoreSymlink cfg.gpgCommitSigning.privateKeyPath;
            };

            ".gnupg/gpg-agent.conf" = lib.mkIf (cfg.gpgCommitSigning.enable && pkgs.stdenv.isDarwin) {
              text = ''
                grab
                default-cache-ttl 60480000
                max-cache-ttl 60480000
                pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
              '';
            };

            ".gnupg/gpg.conf" = lib.mkIf (cfg.gpgCommitSigning.enable && pkgs.stdenv.isDarwin) {
              text = ''
                use-agent
              '';
            };
          };
          activation.setup-gpg = lib.mkIf cfg.gpgCommitSigning.enable (hm.dag.entryAfter ["installPackages"] ''
            ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent
            ${pkgs.gnupg}/bin/gpg --import ${gpgPublicKeyPath}
            ${pkgs.gnupg}/bin/gpg --import ${gpgPrivateKeyPath}
          '');
        };

        programs = {
          git = {
            enable = true;
            userName = cfg.userName;
            userEmail = cfg.email;
            ignores = [
              ".idea"
              "*.DS_Store"
              ".vscode"
              ".terraform"
              "*.iml"
              "pyrightconfig.json"
              "*.swp"
            ];
            lfs = {
              enable = true;
            };
            extraConfig =
              {
                init.defaultBranch = "main";
                core = {
                  editor = "nvim";
                  autocrlf = "input";
                };
                pull.rebase = true;
                push.default = "current";
                rebase.autoStash = true;
              }
              // lib.mkIf cfg.sshAuth.enable (lib.foldl (
                  attrs: host:
                    attrs
                    // {
                      "url.\"ssh://git@${host}/\".insteadOf" = "https://${host}/";
                    }
                ) {}
                cfg.sshAuth.hostnames)
              // lib.mkIf cfg.gpgCommitSigning.enable {
                commit.gpgsign = true;
                gpg.program = "${pkgs.gnupg}/bin/gpg";
                user.signingkey = cfg.gpgCommitSigning.keyId;
              };
          };

          ssh = {
            enable = true;

            extraConfig = lib.mkIf cfg.sshAuth.enable (lib.mkMerge (lib.map (host: ''
                Host ${host}
                  Hostname ${host}
                  IdentityFile ${sshPrivateKeyPath}
              '')
              cfg.sshAuth.hostnames));
          };
        };
      };
  }
