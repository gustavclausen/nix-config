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
    virtualisation.oci-containers.backend = "docker";

    users.users.${systemConfig.user} = {
      extraGroups = [
        "docker"
      ];
    };
  };
}
