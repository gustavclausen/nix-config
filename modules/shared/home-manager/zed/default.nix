{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.zed;
in
with lib;
{
  options.custom.zed = {
    enable = mkEnableOption "Enable Zed editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
      extraPackages = with pkgs; [
        nil
        nixd
        nixfmt
      ];
      extensions = [
        "make"
        "nix"
        "justfile"
      ];
      userSettings = {
        terminal = {
          font_family = "JetBrainsMono Nerd Font";
          shell = "system";
        };
        agent_servers = {
          codex-acp = {
            type = "registry";
          };
          claude-acp = {
            type = "registry";
          };
        };
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        vim_mode = false;
        ui_font_size = 16;
        buffer_font_size = 15;
        theme = {
          mode = "system";
          light = "One Light";
          dark = "One Dark";
        };
      };
    };
  };
}
