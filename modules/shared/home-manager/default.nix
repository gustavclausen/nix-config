{
  pkgs,
  agenix,
  inputs,
  host,
  lib,
  config,
  ...
}: {
  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "24.11";
    file = import ./files.nix {inherit host;};
    packages = import ./packages.nix {inherit pkgs agenix;};
  };

  programs = import ./programs.nix {inherit pkgs inputs host lib config;};

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
    (import ./tmux {inherit pkgs lib inputs config;})
  ];
}
