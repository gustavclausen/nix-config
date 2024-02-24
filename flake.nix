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
        gitUser = {
          userName = "gustavclausen";
          email = "gustav@gustavclausen.com";
          signingKey = "681A1FD6000EE823";
          privSigningKey = "${secrets}/users/gustavclausen_com/github-signing-key.age";
          privSshKey = "${secrets}/systems/personal-mac-mini/github-ssh-key.age";
          pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAt2bSBID4x6m4joRnnxmpRZcKUzqKlOmB4UAkh2jTJi";
          pgpPubKey = ''
            -----BEGIN PGP PUBLIC KEY BLOCK-----

            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
            =eosF
            -----END PGP PUBLIC KEY BLOCK-----
          '';
        };
      };
    };
    "zeronorth-m1-mbp" = mkSystem "zeronorth-m1-mbp" {
      system = "aarch64-darwin";
      user = "gustavclausen";
      gitUser = {
        userName = "gustavclausen";
        email = "gustav.clausen@zeronorth.com";
        signingKey = "03BE49B7B9FB53CA";
        privSigningKey = "${secrets}/users/zeronorth_com/github-signing-key.age";
        privSshKey = "${secrets}/systems/zeronorth-m1-mbp/github-ssh-key.age";
        pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwtmlolIfmJLaVoOTHbGUNkriP4Qds9bU3f3lpnwZf+";
        pgpPubKey = ''
          -----BEGIN PGP PUBLIC KEY BLOCK-----

          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
          =W3eK
          -----END PGP PUBLIC KEY BLOCK-----
        '';
      };
    };
  };
}
