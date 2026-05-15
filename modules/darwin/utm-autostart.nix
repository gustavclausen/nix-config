{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}:
let
  cfg = config.custom.darwin.utm-autostart;
  startScript = pkgs.writeShellScript "utm-autostart" ''
    set -euo pipefail

    sleep ${toString cfg.startDelaySeconds}

    utmctl="${cfg.package}/bin/utmctl"

    "$utmctl" list | tail -n +2 | while read -r uuid status name; do
      if [ -z "''${uuid:-}" ]; then
        continue
      fi

      if [ "$status" = "started" ] || [ "$status" = "starting" ]; then
        echo "Skipping already running VM: $name ($status)"
        continue
      fi

      echo "Starting VM: $name ($status)"
      "$utmctl" --hide start "$name"
    done
  '';
in
{
  options.custom.darwin.utm-autostart = {
    enable = lib.mkEnableOption "automatic startup of all registered UTM virtual machines";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.utm;
      defaultText = lib.literalExpression "pkgs.utm";
      description = "UTM package that provides the utmctl binary.";
    };

    startDelaySeconds = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 30;
      description = "Number of seconds to wait after launchd starts the job before querying UTM.";
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.daemons.utm-autostart.serviceConfig = {
      ProgramArguments = [ "${startScript}" ];
      RunAtLoad = true;
      UserName = systemConfig.user;
      StandardOutPath = "/Users/${systemConfig.user}/Library/Logs/utm-autostart.out.log";
      StandardErrorPath = "/Users/${systemConfig.user}/Library/Logs/utm-autostart.err.log";
      ProcessType = "Background";
    };
  };
}
