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
}
