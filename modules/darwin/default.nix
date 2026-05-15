{ systemConfig, ... }:
{
  system.checks.verifyNixPath = false;

  imports = [
    ../shared
    ./system.nix
    ./home-manager
    ./homebrew.nix
    ./nix-access-tokens.nix
    ./utm-autostart.nix
  ];

  nix = {
    gc = {
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
    };
  };

  users.users.${systemConfig.user} = {
    home = "/Users/${systemConfig.user}";
    isHidden = false;
  };

  age.identityPaths = [
    "/Users/${systemConfig.user}/.ssh/id_ed25519"
  ];
}
