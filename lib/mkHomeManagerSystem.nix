{
  nixpkgs,
  home-manager,
  agenix,
  secrets,
  inputs,
}: name: {
  system,
  user,
  homeDirectory,
  hostConfig,
}: let
  currentSystemUser = user;
in
  home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs agenix secrets currentSystemUser;
      host = "${name}";
    };
    modules = [
      ../modules/shared/home-manager
      hostConfig
      agenix.homeManagerModules.default
      {
        home.username = currentSystemUser;
        home.homeDirectory = homeDirectory;
      }
    ];
  }
