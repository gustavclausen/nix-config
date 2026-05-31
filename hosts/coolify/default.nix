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
    coolify = {
      file = "${secrets}/systems/coolify.age";
      owner = "root";
      group = "root";
      mode = "700";
    };

    coolify-ssh-key = {
      file = "${secrets}/systems/coolify-ssh-key.age";
      owner = "root";
      group = "root";
      mode = "600";
    };

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

  custom.docker.enable = true;

  services.coolify = {
    enable = true;
    domain = "${systemConfig.name}.tail695ae9.ts.net";

    secrets = {
      environmentFile = config.age.secrets.coolify.path;
      sshKeyFile = config.age.secrets.coolify-ssh-key.path;
    };
  };
}
