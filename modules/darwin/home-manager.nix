{
  config,
  pkgs,
  lib,
  currentSystemUser,
  currentSystem,
  gitUser,
  flakeName,
  ...
}: let
  user = currentSystemUser;
  sharedFiles = import ../shared/files.nix {inherit user config pkgs lib flakeName gitUser;};
  additionalFiles = import ./files.nix {inherit user config pkgs;};
in {
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
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
        activation.setup-gpg = lib.hm.dag.entryAfter ["installPackages"] ''
          ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent
          ${pkgs.gnupg}/bin/gpg --import ~/.ssh/pgp_github.pub
          ${pkgs.gnupg}/bin/gpg --import ~/.ssh/pgp_github.key
        '';
      };
      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib currentSystemUser currentSystem gitUser;};
    };
  };
}
