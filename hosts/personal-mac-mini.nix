{
  pkgs,
  currentSystemUser,
  secrets,
  ...
}: {
  home-manager = {
    users.${currentSystemUser} = {
      config,
      pkgs,
      ...
    }: {
      home = {
        file = {
          "${config.home.homeDirectory}/.secrets/github-pat.env" = {
            source = config.lib.file.mkOutOfStoreSymlink "${config.age.secrets."github-pat".path}";
          };
        };

        packages = with pkgs; [claude-code vscode slack];
      };

      age = {
        identityPaths = [
          "${config.home.homeDirectory}/.ssh/id_ed25519"
        ];
        secretsDir = "${config.home.homeDirectory}/.agenix/agenix";
        secretsMountPoint = "${config.home.homeDirectory}/.agenix/agenix.d";

        secrets = {
          "github-pat".file = "${secrets}/systems/personal-mac-mini/github-pat.age";
          "aws".file = "${secrets}/systems/personal-mac-mini/aws.age";
          "github-ssh-key".file = "${secrets}/systems/personal-mac-mini/github-ssh-key.age";
          "github-signing-key".file = "${secrets}/users/gustavclausen_com/github-signing-key.age";
        };
      };

      programs.alacritty.enable = true;
      custom = {
        darwin.dock = {
          enable = true;
          entries = [
            {path = "/Applications/Google Chrome.app/";}
            {path = "/System/Applications/Mail.app/";}
            {path = "/System/Applications/Calendar.app/";}
            {path = "/System/Applications/Notes.app/";}
            {path = "/System/Applications/Messages.app/";}
            {path = "${pkgs.slack}/Applications/Slack.app/";}
            {path = "/Applications/Microsoft Teams.app/";}
            {path = "/Applications/TickTick.app/";}
            {path = "/Applications/Claude.app/";}
            {path = "/Applications/1Password.app/";}
            {path = "/Applications/Spotify.app/";}
            {
              path = "${pkgs.alacritty}/Applications/Alacritty.app/";
            }
            {path = "${pkgs.vscode}/Applications/Visual Studio Code.app/";}
          ];
        };
        neovim.enable = true;
        aws = {
          enable = false;
          configPath = config.age.secrets."aws".path;
        };
        golang.enable = true;
        iac.enable = true;
        nodejs.enable = true;
        k8s.enable = true;
        docker.enable = true;
        tmux.enable = true;
        git = {
          enable = true;
          userName = "gustavclausen";
          email = "gustav@gustavclausen.com";
          sshAuth = {
            enable = true;
            hostnames = ["github.com"];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAt2bSBID4x6m4joRnnxmpRZcKUzqKlOmB4UAkh2jTJi";
            privateKeyPath = config.age.secrets."github-ssh-key".path;
          };
          gpgCommitSigning = {
            enable = true;
            keyId = "681A1FD6000EE823";
            publicKey = ''
              -----BEGIN PGP PUBLIC KEY BLOCK-----

              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
              =eosF
              -----END PGP PUBLIC KEY BLOCK-----
            '';
            privateKeyPath = config.age.secrets."github-signing-key".path;
          };
        };
      };
    };
  };

  homebrew = {
    casks = [
      "microsoft-teams"
    ];
  };
}
