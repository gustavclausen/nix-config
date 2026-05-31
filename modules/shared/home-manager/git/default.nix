{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.git;
in
with lib;
{
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
      default = { };
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
      default = { };
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

    gh = mkOption {
      default = { };
      type = types.submodule {
        options = {
          githubAppAuth = mkOption {
            default = { };
            type = types.submodule {
              options = {
                enable = mkEnableOption "GitHub App authentication";
                refreshBeforeSeconds = mkOption {
                  type = types.ints.positive;
                  default = 300;
                  description = "Refresh the cached GitHub App installation token this many seconds before expiration.";
                };
              };
            };
          };
        };
      };
    };
  };

  config =
    let
      sshHome = "${config.home.homeDirectory}/.ssh";

      sshPublicKeyPath = "${sshHome}/id_git.pub";
      sshPrivateKeyPath = "${sshHome}/id_git";
      gpgPublicKeyPath = "${sshHome}/pgp_git.pub";
      gpgPrivateKeyPath = "${sshHome}/pgp_git.key";
      gpgActivationDependencies = [
        "installPackages"
        "linkGeneration"
        "onFilesChange"
      ]
      ++ lib.optional pkgs.stdenv.isDarwin "setupLaunchAgents";
      ghPackage =
        if cfg.gh.githubAppAuth.enable then
          pkgs.writeShellApplication {
            name = "gh";
            runtimeInputs = with pkgs; [
              coreutils
              curl
              jq
              openssl
              python3
            ];
            text = ''
              app_id="''${GITHUB_APP_ID:-}"
              installation_id="''${GITHUB_APP_INSTALLATION_ID:-}"
              private_key_file="''${GITHUB_APP_PRIVATE_KEY_FILE:-}"
              refresh_before=${toString cfg.gh.githubAppAuth.refreshBeforeSeconds}

              if [[ -z "$app_id" || -z "$installation_id" || -z "$private_key_file" ]]; then
                echo "gh: GITHUB_APP_ID, GITHUB_APP_INSTALLATION_ID, and GITHUB_APP_PRIVATE_KEY_FILE must be set" >&2
                exit 1
              fi

              if [[ ! -r "$private_key_file" ]]; then
                echo "gh: GITHUB_APP_PRIVATE_KEY_FILE is not readable: $private_key_file" >&2
                exit 1
              fi

              cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/gh-github-app-token"
              cache_file="$cache_dir/github.com.json"
              now="$(date +%s)"
              token=""

              expires_at_epoch() {
                python3 -c 'import datetime, sys; print(int(datetime.datetime.fromisoformat(sys.argv[1].replace("Z", "+00:00")).timestamp()))' "$1"
              }

              base64url() {
                openssl base64 -A | tr '+/' '-_' | tr -d '='
              }

              if [[ -s "$cache_file" ]]; then
                cached_token="$(jq -r '.token // empty' "$cache_file" 2>/dev/null || true)"
                cached_expires_at="$(jq -r '.expires_at // empty' "$cache_file" 2>/dev/null || true)"

                if [[ -n "$cached_token" && -n "$cached_expires_at" ]]; then
                  cached_expires_epoch="$(expires_at_epoch "$cached_expires_at" 2>/dev/null || true)"
                  if [[ -n "$cached_expires_epoch" && "$cached_expires_epoch" =~ ^[0-9]+$ && $((cached_expires_epoch - now)) -gt "$refresh_before" ]]; then
                    token="$cached_token"
                  fi
                fi
              fi

              if [[ -z "$token" ]]; then
                iat=$((now - 60))
                exp=$((now + 540))
                header="$(printf '%s' '{"alg":"RS256","typ":"JWT"}' | base64url)"
                payload="$(jq -cn --argjson iat "$iat" --argjson exp "$exp" --arg iss "$app_id" '{iat: $iat, exp: $exp, iss: $iss}' | base64url)"
                signing_input="$header.$payload"
                signature="$(printf '%s' "$signing_input" | openssl dgst -sha256 -sign "$private_key_file" -binary | base64url)"
                jwt="$signing_input.$signature"

                response="$(
                  curl --fail-with-body --silent --show-error \
                    --request POST \
                    --url "https://api.github.com/app/installations/$installation_id/access_tokens" \
                    --header "Accept: application/vnd.github+json" \
                    --header "Authorization: Bearer $jwt" \
                    --header "X-GitHub-Api-Version: 2022-11-28"
                )"

                token="$(printf '%s' "$response" | jq -r '.token // empty')"
                expires_at="$(printf '%s' "$response" | jq -r '.expires_at // empty')"

                if [[ -z "$token" || -z "$expires_at" ]]; then
                  echo "gh: GitHub App installation token response did not include token and expires_at" >&2
                  exit 1
                fi

                install -d -m 700 "$cache_dir"
                umask 077
                tmp_file="$(mktemp "$cache_file.tmp.XXXXXX")"
                jq -cn --arg token "$token" --arg expires_at "$expires_at" '{token: $token, expires_at: $expires_at}' > "$tmp_file"
                mv "$tmp_file" "$cache_file"
              fi

              export GH_TOKEN="$token"
              export GITHUB_TOKEN="$token"
              exec ${pkgs.gh}/bin/gh "$@"
            '';
          }
        else
          pkgs.gh;
    in
    mkIf cfg.enable {
      assertions = lib.mkMerge [
        (lib.mkIf cfg.gpgCommitSigning.enable [
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
        ])
        (lib.mkIf cfg.sshAuth.enable [
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
        ])
      ];

      home = {
        packages =
          with pkgs;
          lib.mkMerge [
            (lib.mkIf cfg.gpgCommitSigning.enable [
              gnupg
              (lib.mkIf pkgs.stdenv.isDarwin pinentry_mac)
            ])
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
        activation.setup-gpg = lib.mkIf cfg.gpgCommitSigning.enable (
          hm.dag.entryAfter gpgActivationDependencies ''
            install -d -m 700 "$HOME/.gnupg"
            chmod 700 "$HOME/.gnupg"
            chmod 700 "$HOME/.gnupg/private-keys-v1.d" 2>/dev/null || true
            chmod 600 "$HOME/.gnupg/pubring.kbx" "$HOME/.gnupg/trustdb.gpg" "$HOME/.gnupg/pubring.kbx~" 2>/dev/null || true

            for _ in {1..30}; do
              [[ -s ${gpgPrivateKeyPath} ]] && break
              verboseEcho "Waiting for GPG private key from agenix at ${gpgPrivateKeyPath}"
              sleep 1
            done

            if [[ ! -s ${gpgPrivateKeyPath} ]]; then
              errorEcho "GPG private key was not created by agenix: ${gpgPrivateKeyPath}"
              exit 1
            fi

            ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent
            ${pkgs.gnupg}/bin/gpg --import ${gpgPublicKeyPath}
            ${pkgs.gnupg}/bin/gpg --import ${gpgPrivateKeyPath}
          ''
        );
      };

      programs = {
        zsh = {
          shellAliases = {
            lg = "lazygit";
          };
        };

        lazygit = {
          enable = true;

          settings = {
            keybinding = {
              commits = {
                moveDownCommit = "<f1>";
                moveUpCommit = "<f2>";
              };
            };
          };
        };

        gh = {
          enable = true;
          package = ghPackage;
        };

        git = {
          enable = true;
          ignores = [
            ".idea"
            "*.DS_Store"
            ".vscode"
            ".terraform"
            "*.iml"
            "pyrightconfig.json"
            "*.swp"
            ".claude/*.local.*"
          ];
          lfs = {
            enable = true;
          };
          settings =
            let
              base = {
                init.defaultBranch = "main";
                core = {
                  editor = "nvim";
                  autocrlf = "input";
                };
                pull.rebase = true;
                push.default = "current";
                rebase.autoStash = true;
                user = {
                  name = cfg.userName;
                  email = cfg.email;
                };
              };

              sshExtra =
                if cfg.sshAuth.enable then
                  (lib.foldl (
                    attrs: host:
                    attrs
                    // {
                      url."ssh://git@${host}/".insteadOf = "https://${host}/";
                    }
                  ) { } cfg.sshAuth.hostnames)
                else
                  { };

              gpgExtra =
                if cfg.gpgCommitSigning.enable then
                  {
                    commit.gpgsign = true;
                    gpg.program = "${pkgs.gnupg}/bin/gpg";
                    user.signingkey = cfg.gpgCommitSigning.keyId;
                  }
                else
                  { };
            in
            lib.recursiveUpdate (lib.recursiveUpdate base sshExtra) gpgExtra;
        };

        ssh = {
          enable = true;
          enableDefaultConfig = false;

          extraConfig = lib.mkIf cfg.sshAuth.enable (
            lib.mkMerge (
              lib.map (host: ''
                Host ${host}
                  Hostname ${host}
                  IdentityFile ${sshPrivateKeyPath}
              '') cfg.sshAuth.hostnames
            )
          );
        };
      };
    };
}
