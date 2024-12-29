{
  agenix,
  pkgs,
  currentSystemUser,
  homePath,
  config,
  lib,
  currentSystem,
  inputs,
  ...
}: {
  imports = [
    ./default.nix
    agenix.homeManagerModules.default
  ];

  home = {
    username = currentSystemUser;
    homeDirectory = homePath;
    stateVersion = "25.05";
    packages = with pkgs; [
      neofetch
    ];
  };
  programs = {
    home-manager.enable = true;
  } // import ../shared/home-manager.nix {inherit config pkgs lib currentSystemUser currentSystem inputs homePath;};
}
