{...}: {
  imports = [
    ./core.nix
    ./system.nix
    ./home-manager.nix
    ./dock
    ../shared
  ];
}
