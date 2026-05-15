host:
{
  system,
  user,
  hostConfig,
}:
{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  agenix,
  disko,
  minimal-tmux,
  agent-skills,
  superpowers,
  anthropic-skills,
  context7-skills,
  mkDeploySshHosts,
}:
let
  systemConfig = {
    name = host;
    user = user;
    system = system;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit
      agenix
      minimal-tmux
      agent-skills
      superpowers
      anthropic-skills
      context7-skills
      mkDeploySshHosts
      systemConfig
      ;
  };

  modules = [
    {
      nixpkgs.overlays = [
        (import ../overlays/direnv.nix)
        (import ../overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
      ];
    }
    disko.nixosModules.disko
    ../modules/nixos
    hostConfig
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      config = {
        _module.args = { inherit systemConfig; };
        home-manager.extraSpecialArgs = {
          inherit
            agenix
            minimal-tmux
            agent-skills
            superpowers
            anthropic-skills
            context7-skills
            mkDeploySshHosts
            systemConfig
            ;
        };
      };
    }
  ];
}
