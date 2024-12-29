{
  pkgs,
  currentSystemUser,
  agenix,
  isHomeManagerConfiguration,
  lib,
  ...
}: let
  nonHomeManagerSettings =
    if !isHomeManagerConfiguration
    then {
      services.nix-daemon.enable = true;
      system.checks.verifyNixPath = false;
      environment.systemPackages = import ../modules/shared/packages.nix {inherit pkgs agenix;};
      nix = {
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
      };
    }
    else {};
in
  {
    imports = [
      ../modules/shared/secrets.nix
      ../modules/shared
    ];

    nix = {
      package = pkgs.nixVersions.git;
      settings.trusted-users = ["@admin" "${currentSystemUser}"];

      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  }
  // nonHomeManagerSettings
