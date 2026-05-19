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

  custom.docker.enable = true;

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
  };

  custom.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };
}
