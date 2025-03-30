{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.nodejs;
in
  with lib; {
    options.custom.nodejs = {
      enable = mkEnableOption "Node.JS development environment";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [nodejs_23 corepack_23];

      programs.zsh.initExtra = ''
        export PATH="$(npm get prefix)/bin:$PATH"
      '';
    };
  }
