{
  homebrew = {
    enable = true;

    casks = [
      "1password"
      "google-chrome"
      "logi-options+"
      "monitorcontrol"
      "raycast"
      "rectangle-pro"
      "spotify"
      "ticktick"
    ];
    brews = ["luarocks"];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {};
  };
}
