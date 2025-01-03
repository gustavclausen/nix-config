{
  currentSystemUser,
  currentSystem,
  host,
  homePath,
  inputs,
  ...
}: let
  user = currentSystemUser;
in {
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: let
      sharedFiles = import ../shared/files.nix {inherit user config pkgs lib host homePath;};
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
      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib currentSystemUser currentSystem host inputs homePath;};
      fonts.fontconfig.enable = true;
    };
  };
}
