{
  nixpkgs,
  nix-homebrew,
  home-manager,
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
  darwin,
  agenix,
  secrets,
  inputs,
}: host: {
  arch,
  user,
}: let
  homePath = "/Users/${user}";
  system = "${arch}-darwin";
in
  darwin.lib.darwinSystem {
    inherit system;

    specialArgs = {
      inherit inputs;
      inherit agenix;
      inherit secrets;
      inherit homePath;
      flakeName = "${host}";
    };

    modules = [
      ../modules/darwin
      ../hosts/darwin/${host}.nix
      home-manager.darwinModules.home-manager
      {
        config._module.args = {
          currentSystem = system;
          currentSystemName = host;
          currentSystemUser = user;
          inputs = inputs;
        };
      }
      nix-homebrew.darwinModules.nix-homebrew
      {
        lib = nixpkgs.lib;
        nix-homebrew = {
          enable = true;
          user = "${user}";
          taps = {
            "homebrew/homebrew-core" = homebrew-core;
            "homebrew/homebrew-cask" = homebrew-cask;
            "homebrew/homebrew-bundle" = homebrew-bundle;
          };
          mutableTaps = false;
        };
      }
      agenix.darwinModules.default
    ];
  }
