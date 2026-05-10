{
  nixpkgs,
  home-manager,
  agenix,
  secrets,
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
    inherit inputs agenix secrets;
    host = "${host}";
  };

  modules = [
    {
      nixpkgs.overlays = [
        (import ../overlays/direnv.nix)
        (import ../overlays/unstable-packages.nix { nixpkgs-unstable = inputs.nixpkgs-unstable; })
      ];
    }
    ../modules/nixos
    hostConfig
    agenix.nixosModules.default
    {
      home-manager = {
        users.${user} =
          { ... }:
          {
            imports = [
              agenix.homeManagerModules.default
            ];
          };
      };
    }
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
