{...}: {
  imports = [
    ./core.nix
    ./system.nix
    ./home-manager.nix
    ./homebrew.nix
    ./dock
    ../shared
  ];
}
