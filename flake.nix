{
  description = "gustavclausen's Nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
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
  };
  outputs = {
    self,
    darwin,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    home-manager,
    nixpkgs,
    agenix,
    secrets,
  } @ inputs: let
    darwinSystems = ["aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs darwinSystems f;
    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = with pkgs;
        mkShell {
          nativeBuildInputs = with pkgs; [bashInteractive git yubikey-manager age age-plugin-yubikey];
          shellHook = ''
            export EDITOR=vim
          '';
        };
    };

    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs inputs nix-homebrew home-manager homebrew-core homebrew-cask homebrew-bundle darwin agenix secrets;
    };
  in {
    devShells = forAllSystems devShell;

    darwinConfigurations = {
      "personal-mac-mini" = mkSystem "personal-mac-mini" {
        system = "aarch64-darwin";
        user = "gustavclausen";
      };
      "zeronorth-m1-mbp" = mkSystem "zeronorth-m1-mbp" {
        system = "aarch64-darwin";
        user = "gustavclausen";
      };
    };
  };
}
