{
  systemConfig,
  secrets,
  config,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";

  custom.serverProfile = {
    enable = true;
    coolifyAccess = true;
  };

  home-manager = {
    users.${systemConfig.user} =
      {
        ...
      }:
      {
        home = {
          packages = [ ];
        };

        custom.docker.enable = true;
      };
  };

  age.secrets = {
    tailscale = {
      file = "${secrets}/systems/tailscale.age";
      owner = "root";
      group = "root";
      mode = "600";
    };

    cloudflared-tunnel = {
      file = "${secrets}/systems/cloudflare-tunnel-gustavclausen.age";
      owner = "root";
      group = "root";
      mode = "600";
    };

    coolify-proxy = {
      file = "${secrets}/systems/coolify-proxy.age";
      owner = "root";
      group = "root";
      mode = "600";
    };
  };
  custom.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };

  custom.docker.enable = true;

  services.coolifyProxy = {
    enable = true;
    dnsProvider = "cloudflare";
    environmentFile = config.age.secrets.coolify-proxy.path;

    domains = [
      {
        main = "gustavclausen.com";
        sans = [ "*.gustavclausen.com" ];
      }
    ];
  };

  custom.cloudflared = {
    enable = true;
    tunnelId = "582d60ba-f8f3-4327-8d54-2b55799baf76";
    credentialsFile = config.age.secrets.cloudflared-tunnel.path;
  };
}
