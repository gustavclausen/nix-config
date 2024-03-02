{
  lib,
  currentSystemUser,
  config,
  pkgs,
  homePath,
  ...
}:
with lib; let
  cfg = config.local.git;

  sshHome = "${homePath}/.ssh";
in {
  options.local.git = {
    enable = mkEnableOption "Git config";

    userName = mkOption {
      description = "Username of local Git user";
      type = types.str;
    };

    email = mkOption {
      description = "Email of local Git user";
      type = types.str;
    };

    ssh = mkOption {
      type = types.submodule {
        options = {
          publicKey = mkOption {
            description = "Public SSH key";
            type = types.str;
          };
          privateKey = mkOption {
            description = "Path to age secret containing private SSH key";
            type = types.str;
          };
        };
      };
    };

    signing = mkOption {
      type = types.submodule {
        options = {
          key = mkOption {
            description = "Public PGP signing key";
            type = types.str;
          };
          publicKey = mkOption {
            description = "Public PGP key for signing";
            type = types.str;
          };
          privateKey = mkOption {
            description = "Path to age secret containing private PGP signing key";
            type = types.str;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${currentSystemUser} = {lib, ...}: {
      home = {
        file = {
          ".ssh/id_github.pub" = {
            text = cfg.ssh.publicKey;
          };

          ".ssh/pgp_github.pub" = {
            text = cfg.signing.publicKey;
          };

          "test.txt" = {
            text = cfg.signing.privateKey;
          };
        };

        activation.setup-gpg = lib.hm.dag.entryAfter ["installPackages"] ''
          ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent
          ${pkgs.gnupg}/bin/gpg --import ${sshHome}/pgp_github.pub
          ${pkgs.gnupg}/bin/gpg --import ${sshHome}/pgp_github.key
        '';
      };

      programs = {
        git = {
          userName = cfg.userName;
          userEmail = cfg.email;
          extraConfig = {
            user.signingkey = cfg.signing.key;
          };
        };
      };
    };

    age.secrets."github-ssh-key" = {
      symlink = true;
      path = "${sshHome}/id_github";
      file = cfg.ssh.privateKey;
      mode = "600";
      owner = currentSystemUser;
      group = "staff";
    };

    age.secrets."github-signing-key" = {
      symlink = true;
      path = "${sshHome}/pgp_github.key";
      file = cfg.signing.privateKey;
      mode = "600";
      owner = currentSystemUser;
    };
  };
}
