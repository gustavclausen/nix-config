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
  getHostAttr = fileName: attrName: defaultVal: {args ? {}}: let
    hostConfig = ../hosts/darwin/${host}/${fileName};
  in
    if builtins.pathExists hostConfig
    then let
      file =
        if args == {}
        then import hostConfig
        else import hostConfig args;
    in
      if builtins.hasAttr attrName file
      then file.${attrName}
      else defaultVal
    else defaultVal;

  sharedConfig = {pkgs, ...}: {
    homebrew = {
      casks = pkgs.callPackage ../modules/darwin/casks.nix {
        extra = getHostAttr "homebrew.nix" "extraCasks" [] {args = {inherit inputs;};};
      };
      brews = pkgs.callPackage ../modules/darwin/brews.nix {
        extra = getHostAttr "homebrew.nix" "extraBrews" [] {args = {inherit inputs;};};
      };
    };

    home-manager = {
      users.${user} = {
        config,
        pkgs,
        ...
      }: {
        home = {
          packages = pkgs.callPackage ../modules/darwin/packages.nix {
            inherit pkgs agenix;
            extra = getHostAttr "packages.nix" "extraUserPackages" [] {
              args = {inherit pkgs;};
            };
          };
        };
      };
    };
  };
in
  darwin.lib.darwinSystem {
    inherit system;

    specialArgs = {
      inherit inputs;
      inherit agenix;
      inherit secrets;
      inherit homePath;
      host = "${host}";
    };

    modules = [
      ../modules/darwin
      ../hosts/darwin/${host}
      sharedConfig
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
          taps =
            {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            }
            // (getHostAttr "homebrew.nix" "extraTaps" {} {
              args = {inherit inputs;};
            });
          mutableTaps = false;
        };
      }
      agenix.darwinModules.default
    ];
  }
