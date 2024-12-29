{pkgs, ...}: {
  home = rec {
    username = "gustavclausen";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      neofetch
    ];
  };
  programs.home-manager.enable = true;
  nix = {
    enable = true;
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # programs.git = {
  #  enable = true;
  #  userName = "Jane Doe";
  #  userEmail = "jane.doe@example.org";
  #};
}
