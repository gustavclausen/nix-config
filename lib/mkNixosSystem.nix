host:
{
  system,
  user,
  hostConfig,
}:
{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  agenix,
  disko,
  minimal-tmux,
}:
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit agenix minimal-tmux;
    host = "${host}";
  };

  modules = [
    {
      nixpkgs.overlays = [
        (import ../overlays/direnv.nix)
        (import ../overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
      ];
    }
    disko.nixosModules.disko
    ../modules/nixos
    hostConfig
    home-manager.nixosModules.home-manager
    {
      config = {
        _module.args = {
          currentSystem = system;
          currentSystemName = host;
          currentSystemUser = user;
        };
        home-manager.extraSpecialArgs = {
          inherit agenix minimal-tmux;
          host = "${host}";
        };
      };
    }
  ];
}
