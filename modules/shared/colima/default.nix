{
  config,
  lib,
  homePath,
  ...
}:
with lib; let
  cfg = config.local.colima;
in {
  options = {
    local.colima.enable = mkOption {
      description = "Enable colima";
      default = false;
      example = true;
    };
  };

  config =
    mkIf cfg.enable
    {
      system.activationScripts.postUserActivation.text = ''
        if [[ ! -L /var/run/docker.sock ]] && [[ ! -e /var/run/docker.sock ]]; then
          sudo ln -s ${homePath}/.colima/docker.sock /var/run/docker.sock
        fi
      '';
    };
}
