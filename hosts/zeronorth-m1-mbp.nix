{
  agenix,
  pkgs,
  currentSystemUser,
  secrets,
  ...
}: let
  homePath =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${currentSystemUser}"
    else "/home/${currentSystemUser}";
in {
  homebrew = {
    casks = pkgs.callPackage ../modules/darwin/casks.nix {extra = ["aws-vpn-client" "inkscape" "google-drive" "linear-linear"];};
  };

  home-manager = {
    users.${currentSystemUser} = {
      home = {
        packages = pkgs.callPackage ../modules/darwin/packages.nix {
          extra = with pkgs; [
            argocd
            aws-sam-cli
            helm-docs
            helmfile
            k6
            k9s
            kubectl
            kubernetes-helm
            poetry
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

  imports = [
    ./default.nix
    ../modules/darwin/home-manager.nix
    ../modules/darwin/dock
    agenix.darwinModules.default
  ];

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
    {path = "/Applications/1Password.app/";}
    {path = "/Applications/Spotify.app/";}
    {
      path = "${pkgs.alacritty}/Applications/Alacritty.app/";
    }
    {
      path = "/Applications/AWS VPN Client/AWS VPN Client.app/";
    }
  ];
}
