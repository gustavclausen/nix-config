{
  pkgs,
  currentSystemUser,
  agenix,
  ...
}: {
  imports = [
    ../modules/shared
    ../modules/shared/secrets.nix
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nixUnstable;
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

  system.checks.verifyNixPath = false;

  environment.systemPackages = [agenix.packages."${pkgs.system}".default] ++ (import ../modules/shared/packages.nix {inherit pkgs;});

  fonts.fontDir.enable = true;
}
