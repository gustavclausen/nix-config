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
  hostConfig,
}: let
  system = "${arch}-darwin";
in
  darwin.lib.darwinSystem {
    inherit system;

    specialArgs = {
      inherit inputs agenix secrets;
      host = "${host}";
    };

    modules = [
      ../modules/darwin
      hostConfig
      agenix.darwinModules.default
      {
        home-manager = {
          users.${user} = {
            config,
            pkgs,
            ...
          }: {
            imports = [
              agenix.homeManagerModules.default
            ];
          };
        };
      }
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
    ];
  }
