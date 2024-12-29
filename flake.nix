
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
    home-manager,
    nixpkgs,
    agenix,
    secrets,
    minimal-tmux,
  } @ inputs: let
    darwinSystems = ["aarch64-darwin"];
    linuxSystems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
    devShell = system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      default = with pkgs;
        mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git yubikey-manager age age-plugin-yubikey nix pkgs.home-manager ];
          NIX_CONFIG = "experimental-features = nix-command flakes";
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

    homeConfigurations = {
      "parallels" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config = {
            allowUnfree = true;
          };
        };
        # extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/parallels.nix
        ];
      };
    };
  };
}

