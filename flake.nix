{
  description = "gustavclausen's Nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    secrets = {
      url = "git+ssh://git@github.com/gustavclausen/nix-secrets.git";
      flake = false;
    };
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs =
    {
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      home-manager,
      nixpkgs,
      agenix,
      secrets,
      minimal-tmux,
      disko,
      nixpkgs-unstable,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
                yubikey-manager
                age
                age-plugin-yubikey
                just
              ];
              shellHook = ''
                export EDITOR=vim
              '';
            };
        };

      mkDarwinSystem = import ./lib/mkDarwinSystem.nix;
      mkNixosSystem = import ./lib/mkNixosSystem.nix;
      darwinSystemArgs = {
        inherit
          nixpkgs
          nixpkgs-unstable
          nix-homebrew
          home-manager
          homebrew-core
          homebrew-cask
          homebrew-bundle
          darwin
          agenix
          minimal-tmux
          ;
      };
      nixosSystemArgs = {
        inherit
          nixpkgs
          nixpkgs-unstable
          home-manager
          agenix
          disko
          minimal-tmux
          ;
      };
    in
    {
      lib = {
        inherit mkDarwinSystem mkNixosSystem;
      };

      devShells = forAllSystems devShell;

      darwinConfigurations = {
        "personal-macbook-pro-m5" = mkDarwinSystem "personal-macbook-pro-m5" {
          arch = "aarch64";
          user = "gustavkc";
          hostConfig =
            { systemConfig, ... }@args:
            import ./hosts/personal-macbook-pro-m5.nix (
              args
              // {
                inherit systemConfig secrets;
              }
            );
        } darwinSystemArgs;
      };

      nixosConfigurations = {
        "coolify" = mkNixosSystem "coolify" {
          system = "aarch64-linux";
          user = "nixos";
          hostConfig = import ./hosts/coolify.nix;
        } nixosSystemArgs;
      };
    };
}
