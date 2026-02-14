{...}: {
  imports = [
    ./core.nix
    ./system.nix
    ./home-manager
    ./homebrew.nix
    ./overlays.nix
  ];
}
