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
      url = "github:gustavclausen/nix-secrets";
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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
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
      disko,
      nixpkgs-unstable,
      deploy-rs,
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
                just
                pkgs.deploy-rs
              ];
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

      mkDeploy =
        host:
        {
          hostname,
          system,
          sshUser ? "nixos",
          user ? "root",
          remoteBuild ? true,
          ...
        }:
        {
          inherit
            hostname
            sshUser
            user
            remoteBuild
            ;

          profiles.system = {
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${host};
          };
        };

      mkDarwinHost = host: hostConfig: mkDarwinSystem host hostConfig darwinSystemArgs;
      mkNixosHost =
        host:
        {
          system,
          user ? "nixos",
          hostConfig,
          ...
        }:
        mkNixosSystem host {
          inherit system user hostConfig;
        } nixosSystemArgs;

      hosts = {
        darwin = {
          "personal-macbook-pro-m5" = {
            arch = "aarch64";
            user = "gustavkc";
            hostConfig =
              { ... }:
              {
                imports = [ ./hosts/personal-macbook-pro-m5 ];
                _module.args = {
                  inherit secrets deployHosts;
                };
              };
          };
        };

        nixos = {
          coolify = {
            system = "aarch64-linux";
            hostConfig =
              { ... }:
              {
                imports = [ ./hosts/coolify ];
                _module.args = {
                  inherit secrets;
                };
              };
            deploy = { };
          };
        };
      };

      deployHosts = nixpkgs.lib.mapAttrs (
        host:
        {
          system,
          deploy,
          ...
        }:
        {
          hostname = deploy.hostname or host;
          sshUser = deploy.sshUser or "nixos";
          user = deploy.user or "root";
          remoteBuild = deploy.remoteBuild or true;
          system = deploy.system or system;
        }
      ) (nixpkgs.lib.filterAttrs (_: hostConfig: hostConfig ? deploy) hosts.nixos);
    in
    {
      lib = {
        inherit mkDarwinSystem mkNixosSystem;
      };

      devShells = forAllSystems devShell;

      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwinHost hosts.darwin;

      nixosConfigurations = nixpkgs.lib.mapAttrs mkNixosHost hosts.nixos;

      deploy.nodes = nixpkgs.lib.mapAttrs mkDeploy deployHosts;
    };
}
