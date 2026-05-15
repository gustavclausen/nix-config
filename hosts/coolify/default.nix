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

  home-manager = {
    users.${systemConfig.user} =
      {
        ...
      }:
      {
        home = {
          packages = [ ];
        };

        custom = {
          nodejs.enable = true;
        };
      };
  };

  age.secrets.tailscale = {
    file = "${secrets}/systems/tailscale.age";
    path = "/var/run/secrets/tailscale";
    owner = "root";
    group = "root";
    mode = "700";
  };
  custom.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };

  custom.docker.enable = true;
}
