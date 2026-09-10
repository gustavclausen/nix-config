{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.cloudflared;
in
with lib;
{
  options.custom.cloudflared = {
    enable = mkEnableOption "Cloudflare Tunnel (cloudflared)";

    tunnelId = mkOption {
      type = types.str;
      default = "";
      example = "00000000-0000-0000-0000-000000000000";
      description = "UUID of the Cloudflare tunnel to run.";
    };

    credentialsFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/var/run/secrets/cloudflared";
      description = "Runtime path to the tunnel credentials JSON file (from `cloudflared tunnel create`).";
    };

    ingress = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        "app.example.com" = "http://localhost:8080";
      };
      description = "Hostname to local service mappings for the tunnel.";
    };

    default = mkOption {
      type = types.str;
      default = "http_status:404";
      description = "Catch-all service used when no ingress rule matches.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tunnelId != "";
        message = "custom.cloudflared.tunnelId must be set when custom.cloudflared.enable is true.";
      }
      {
        assertion = cfg.credentialsFile != null;
        message = "custom.cloudflared.credentialsFile must be set when custom.cloudflared.enable is true.";
      }
    ];

    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = cfg.credentialsFile;
        ingress = cfg.ingress;
        default = cfg.default;
      };
    };
  };
}
