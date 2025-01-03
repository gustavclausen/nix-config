{
  pkgs,
  currentSystemUser,
  currentSystem,
  flakeName,
  homePath,
  inputs,
  ...
}: let
  user = currentSystemUser;
in {
  users.users.${user} = {
    name = user;
    home = homePath;
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: let
      sharedFiles = import ../shared/files.nix {inherit user config pkgs lib flakeName homePath;};
      additionalFiles = import ./files.nix {inherit user config pkgs homePath;};
    in {
      xdg.enable = true;
      home = {
        enableNixpkgsReleaseCheck = false;
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        stateVersion = "24.11";
      };
      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib currentSystemUser currentSystem inputs homePath;};
      fonts.fontconfig.enable = true;
    };
  };
}
