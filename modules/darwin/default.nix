{ systemConfig, ... }:
{
  system.checks.verifyNixPath = false;

  imports = [
    ../shared
    ./system.nix
    ./home-manager
    ./homebrew.nix
  ];

  users.users.${systemConfig.user} = {
    home = "/Users/${systemConfig.user}";
    isHidden = false;
  };
}
