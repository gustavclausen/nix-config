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
let
  systemConfig = {
    name = host;
    user = user;
    system = system;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit agenix minimal-tmux systemConfig;
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
        _module.args = { inherit systemConfig; };
        home-manager.extraSpecialArgs = {
          inherit agenix minimal-tmux systemConfig;
        };
      };
    }
  ];
}
