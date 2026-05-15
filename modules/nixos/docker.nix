{
  lib,
  config,
  systemConfig,
  ...
}:
let
  cfg = config.custom.docker;
in
with lib;
{
  options.custom.docker = {
    enable = mkEnableOption "Docker";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    users.users.${systemConfig.user} = {
      extraGroups = [
        "docker"
      ];
    };
  };
}
