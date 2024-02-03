{
  agenix,
  pkgs,
  ...
}: {
  homebrew = {
    casks = pkgs.callPackage ../modules/darwin/casks.nix {extra = [];};
  };

  imports = [
    ./default.nix
    ../modules/darwin/home-manager.nix
    ../modules/darwin/dock
    agenix.darwinModules.default
  ];

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
        "com.apple.swipescrolldirection" = false;

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
    {path = "/System/Applications/Messages.app/";}
    {path = "/Applications/Slack.app/";}
    {path = "/System/Applications/Mail.app/";}
    {path = "/System/Applications/Calendar.app/";}
    {path = "/Applications/Obsidian.app/";}
    {path = "/Applications/TickTick.app/";}
    {
      path = "${pkgs.alacritty}/Applications/Alacritty.app/";
    }
    {path = "/Applications/1Password.app/";}
    {path = "/Applications/Spotify.app/";}
  ];
}
