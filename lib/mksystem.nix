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

  systemFunc =
    if isDarwinHost
    then darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  homeManagerModules =
    if isDarwinHost
    then home-manager.darwinModules
    else home-manager.nixosModules;

  nixBrew =
    if isDarwinHost
    then
      (nix-homebrew.darwinModules.nix-homebrew
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
        })
    else {};
in
  systemFunc rec {
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
      homeManagerModules.home-manager
      {
        config._module.args = {
          currentSystem = system;
          currentSystemName = name;
          currentSystemUser = user;
          inputs = inputs;
        };
      }
      nixBrew
    ];
  }
