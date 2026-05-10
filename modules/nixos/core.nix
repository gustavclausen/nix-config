{
  lib,
  pkgs,
  systemConfig,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  networking.hostName = lib.mkDefault systemConfig.name;

  nix = {
    package = pkgs.nixVersions.git;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@wheel"
        systemConfig.user
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  users.users.${systemConfig.user} = {
    isNormalUser = true;
    home = "/home/${systemConfig.user}";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
    ];
  };

  programs.zsh.enable = true;

  system.stateVersion = lib.mkDefault "25.11";
}
