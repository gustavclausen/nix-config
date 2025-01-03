{
  description = "gustavclausen's Nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    homebrew-argoproj = {
      url = "github:argoproj/homebrew-tap";
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
  };
  outputs = {
    self,
    darwin,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    homebrew-argoproj,
    home-manager,
    nixpkgs,
    agenix,
    secrets,
    minimal-tmux,
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

    mkDarwinSystem = import ./lib/mkDarwinSystem.nix {
      inherit nixpkgs inputs nix-homebrew home-manager homebrew-core homebrew-cask homebrew-bundle darwin agenix secrets;
    };
  in {
    devShells = forAllSystems devShell;

    darwinConfigurations = {
      "personal-mac-mini" = mkDarwinSystem "personal-mac-mini" {
        arch = "aarch64";
        user = "gustavclausen";
      };
      "zeronorth-m1-mbp" = mkDarwinSystem "zeronorth-m1-mbp" {
        arch = "aarch64";
        user = "gustavclausen";
      };
    };
  };
}
