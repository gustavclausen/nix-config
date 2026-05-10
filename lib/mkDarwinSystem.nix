host:
{
  arch,
  user,
  hostConfig,
}:
{
  nixpkgs,
  nixpkgs-unstable,
  nix-homebrew,
  home-manager,
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
  darwin,
  agenix,
  minimal-tmux,
}:
let
  system = "${arch}-darwin";
in
darwin.lib.darwinSystem {
  inherit system;

  specialArgs = {
    inherit agenix minimal-tmux;
    host = "${host}";
  };

  modules = [
    {
      nixpkgs.config.permittedInsecurePackages = [ "lima-full-1.2.2" ];
      nixpkgs.overlays = [
        (import ../overlays/direnv.nix)
        (import ../overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
      ];
    }
    ../modules/darwin
    hostConfig
    agenix.darwinModules.default
    {
      home-manager = {
        users.${user} =
          {
            ...
          }:
          {
            imports = [
              agenix.homeManagerModules.default
            ];
          };
      };
    }
    home-manager.darwinModules.home-manager
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
