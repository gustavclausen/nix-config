{
  agenix,
  pkgs,
  currentSystemUser,
  homePath,
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
  programs.home-manager.enable = true;
}
