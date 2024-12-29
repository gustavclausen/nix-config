{
  pkgs,
  currentSystemUser,
  agenix,
  isHomeConfiguration,
  lib,
  ...
}: let 
  nonHomeManagerSettings = if !isHomeConfiguration then {
    services.nix-daemon.enable = true;
    system.checks.verifyNixPath = false;
    environment.systemPackages = import ../modules/shared/packages.nix {inherit pkgs agenix;};
  } else {};
in {
  imports = [
    ../modules/shared/secrets.nix
    ../modules/shared
  ];

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

} // nonHomeManagerSettings
