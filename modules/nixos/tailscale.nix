{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.tailscale;
in
with lib;
{
  options.custom.tailscale = {
    enable = mkEnableOption "Tailscale";

    authKeyFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/var/run/secrets/tailscale";
      description = "Runtime path to the Tailscale auth key file.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.authKeyFile != null;
        message = "custom.tailscale.authKeyFile must be set when custom.tailscale.enable is true.";
      }
    ];

    services.tailscale = {
      enable = true;
      authKeyFile = cfg.authKeyFile;
    };

    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    networking.firewall = {
      allowedUDPPorts = [ 41641 ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
