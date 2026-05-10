{
  pkgs,
  agenix,
  systemConfig,
  lib,
  config,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "24.11";
    file = import ./files.nix { host = systemConfig.name; };
    packages = import ./packages.nix { inherit pkgs agenix; };
  };

  programs = import ./programs.nix {
    inherit
      pkgs
      lib
      config
      ;
  };

  imports = [
    ./aws
    ./docker
    ./dotnet
    ./git
    ./golang
    ./iac
    ./k8s
    ./nodejs
    ./nvim
    ./ssh
    ./tmux
  ];
}
