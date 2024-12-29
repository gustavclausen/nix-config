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
  outputs,
}: name: {
  system,
  user,
}: let
  hostConfig = ../hosts/${name}.nix;

  isDarwinHost = nixpkgs.lib.strings.hasInfix "darwin" system;

  homePath =
    if isDarwinHost
    then "/Users/${user}"
    else "/home/${user}";
in
  if isDarwinHost
  then
    darwin.lib.darwinSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        inherit agenix;
        inherit secrets;
        inherit homePath;
        flakeName = "${name}";
      };

      modules = [
        hostConfig
        home-manager.darwinModules.home-manager
        {
          config._module.args = {
            currentSystem = system;
            currentSystemName = name;
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
  else
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit inputs outputs agenix secrets homePath;
        flakeName = "${name}";
      };
      modules = [
        hostConfig
      ];
    }
