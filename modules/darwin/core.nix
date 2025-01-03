{
  pkgs,
  currentSystemUser,
  ...
}: {
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  system.checks.verifyNixPath = false;

  nix = {
    package = pkgs.nixVersions.git;
    settings.trusted-users = ["@admin" "${currentSystemUser}"];

    gc = {
      user = "root";
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
}
