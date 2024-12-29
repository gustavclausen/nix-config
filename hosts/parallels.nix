{
  pkgs,
  currentSystemUser,
  homePath,
  inputs,
  outputs,
}: {
  imports = [
    ./default.nix
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
