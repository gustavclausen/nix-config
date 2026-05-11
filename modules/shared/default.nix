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
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
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
