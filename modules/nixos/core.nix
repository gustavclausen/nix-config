{
  lib,
  pkgs,
  currentSystemUser,
  host,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  networking.hostName = lib.mkDefault host;

  nix = {
    package = pkgs.nixVersions.git;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@wheel"
        currentSystemUser
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  users.users.${currentSystemUser} = {
    isNormalUser = true;
    home = "/home/${currentSystemUser}";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
    ];
  };

  programs.zsh.enable = true;

  system.stateVersion = lib.mkDefault "25.11";
}
