{
  agenix,
  pkgs,
  currentSystemUser,
  homePath,
  ...
}: {
  imports = [
    ./default.nix
    ../modules/shared/home-manager.nix
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
  programs.home-manager.enable = true;
}
