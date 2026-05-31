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

  services.coolifyProxy.enable = true;

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

    github-app-gustavclausen-ai = {
      file = "${secrets}/systems/github-app-gustavclausen-ai.age";
      owner = "paperclip";
      group = "paperclip";
      mode = "600";
    };

    github-app-gustavclausen-ai-private-key = {
      file = "${secrets}/systems/github-app-gustavclausen-ai-private-key.age";
      owner = "paperclip";
      group = "paperclip";
      mode = "600";
    };

    context7 = {
      file = "${secrets}/systems/context7.age";
      owner = "paperclip";
      group = "paperclip";
      mode = "600";
    };
  };

  custom.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };

  custom.paperclip = {
    enable = true;
    git = {
      userName = "gustavclausen-ai[bot]";
      email = "287174710+gustavclausen-ai[bot]@users.noreply.github.com";
      githubAppAuth = {
        environmentFile = config.age.secrets.github-app-gustavclausen-ai.path;
        privateKeyFile = config.age.secrets.github-app-gustavclausen-ai-private-key.path;
      };
    };
    context7.environmentFile = config.age.secrets.context7.path;
  };
}
