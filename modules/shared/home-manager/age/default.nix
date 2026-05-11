{
  lib,
  config,
  pkgs,
  agenix,
  ...
}:
let
  cfg = config.custom.age;
in
with lib;
{
  options.custom.age = {
    enable = mkEnableOption "Age tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      age-plugin-yubikey
      agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      yubikey-manager
    ];
  };
}
