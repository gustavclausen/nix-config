{
  agenix,
  pkgs,
  currentSystemUser,
  secrets,
  homePath,
  ...
}: {
  imports = [
    ./default.nix
    ../modules/darwin/home-manager.nix
    ../modules/darwin/dock
    agenix.darwinModules.default
  ];

  homebrew = {
    casks = pkgs.callPackage ../modules/darwin/casks.nix {extra = ["another-redis-desktop-manager" "aws-vpn-client" "inkscape" "google-drive" "linear-linear" "notion" "pritunl"];};
  };

  home-manager = {
    users.${currentSystemUser} = {
      home = {
        packages = pkgs.callPackage ../modules/darwin/packages.nix {
          extra = with pkgs; [
            argocd
            aws-nuke
            cloud-custodian
            copier
            eksctl
            helm-docs
            helmfile
            istioctl
            k6
            k9s
            kind
            kubectl
            kubernetes-helm
            kubeswitch
            kustomize
            kyverno
            ngrok
            poetry
            pyenv
            redis
            slack
            terraform
            terraform-docs
            tflint
          ];
        };
      };
    };
  };

  local.git = {
    enable = true;
    userName = "gustavclausen";
    email = "gustav.clausen@zeronorth.com";
    ssh = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHJBLNvX+qaiYFnOoOwJjdYfpKS1Q3uB0Za/wfMjShL";
      privateKey = "${secrets}/systems/zeronorth-m1-mbp/github-ssh-key.age";
    };
    signing = {
      key = "03BE49B7B9FB53CA";
      publicKey = ''
        -----BEGIN PGP PUBLIC KEY BLOCK-----

        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
        =W3eK
        -----END PGP PUBLIC KEY BLOCK-----
      '';
      privateKey = "${secrets}/users/zeronorth_com/github-signing-key.age";
    };
  };

  age.secrets."github-pat" = {
    symlink = true;
    path = "${homePath}/.secrets/github-pat.env";
    file = "${secrets}/systems/zeronorth-m1-mbp/github-pat.age";
    mode = "600";
    owner = "${currentSystemUser}";
    group = "staff";
  };

  age.secrets."aws" = {
    symlink = true;
    path = "${homePath}/.aws/config";
    file = "${secrets}/systems/zeronorth-m1-mbp/aws.age";
    mode = "600";
    owner = "${currentSystemUser}";
    group = "staff";
  };

  age.secrets."zn-jumphosts" = {
    symlink = true;
    path = "${homePath}/.ssh/config.d/zn-jumphosts";
    file = "${secrets}/systems/zeronorth-m1-mbp/jumphosts.age";
    mode = "600";
    owner = "${currentSystemUser}";
    group = "staff";
  };

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = true;

        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
      };

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = false;
        orientation = "bottom";
        tilesize = 48;
        minimize-to-application = true;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        _FXShowPosixPathInTitle = false;
        FXPreferredViewStyle = "Nlsv";
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      spaces = {
        spans-displays = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
    };
  };

  local.dock.enable = true;
  local.dock.entries = [
    {path = "/Applications/Google Chrome.app/";}
    {
      path = "${pkgs.slack}/Applications/Slack.app/";
    }
    {
      path = "/Users/${currentSystemUser}/Applications/Chrome Apps.localized/Gmail.app/";
    }
    {
      path = "/Users/${currentSystemUser}/Applications/Chrome Apps.localized/Google Calendar.app/";
    }
    {
      path = "/Applications/Linear.app/";
    }
    {path = "/Applications/Obsidian.app/";}
    {path = "/Applications/Notion.app/";}
    {path = "/Applications/1Password.app/";}
    {path = "/Applications/Spotify.app/";}
    {
      path = "${pkgs.alacritty}/Applications/Alacritty.app/";
    }
    {path = "/Applications/Pritunl.app/";}
  ];
}
