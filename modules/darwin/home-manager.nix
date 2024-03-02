{
  config,
  pkgs,
  lib,
  currentSystemUser,
  currentSystem,
  flakeName,
  homePath,
  ...
}: let
  user = currentSystemUser;
  sharedFiles = import ../shared/files.nix {inherit user config pkgs lib flakeName homePath;};
  additionalFiles = import ./files.nix {inherit user config pkgs homePath;};
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

  nixpkgs.config = {
    allowUnfree = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      xdg.enable = true;
      home = {
        enableNixpkgsReleaseCheck = false;
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib currentSystemUser currentSystem;};
    };
  };
}
