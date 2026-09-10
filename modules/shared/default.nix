{
  pkgs,
  systemConfig,
  ...
}:
{
  imports = [
    ./home-manager
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.git;
    settings.trusted-users = [
      "@admin"
      systemConfig.user
    ];

    gc = {
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users.${systemConfig.user} = {
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Records which flake host config this system was last switched to, so
  # `just switch` (without an explicit host) can auto-detect it.
  environment.etc."current-nix-host".text = systemConfig.name;
}
