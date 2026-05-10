{
  nixpkgs,
  home-manager,
  inputs,
}:
host:
{
  system,
  user,
  hostConfig,
}:
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs;
    host = "${host}";
  };

  modules = [
    {
      nixpkgs.overlays = [
        (import ../overlays/direnv.nix)
        (import ../overlays/unstable-packages.nix { nixpkgs-unstable = inputs.nixpkgs-unstable; })
      ];
    }
    inputs.disko.nixosModules.disko
    ../modules/nixos
    hostConfig
    home-manager.nixosModules.home-manager
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = host;
        currentSystemUser = user;
        inputs = inputs;
      };
    }
  ];
}
