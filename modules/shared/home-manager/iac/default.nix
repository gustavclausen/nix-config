{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.iac;
in
  with lib; {
    options.custom.iac = {
      enable = mkEnableOption "Infrastructure as Code (IaC) tools";
    };

    config = mkIf cfg.enable {
      home = {
        packages = with pkgs; [opentofu terraform-docs];

        file = {
          ".local/share/bin/terraform".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.opentofu}/bin/tofu";
        };
      };
    };
  }
