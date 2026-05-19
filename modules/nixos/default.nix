{
  lib,
  systemConfig,
  ...
}:
{
  imports = [
    ../shared
    ./docker.nix
    ./home-manager.nix
    ./tailscale.nix
    ./server-profile.nix
    ./coolify.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.users = {
    root = {
      hashedPassword = "!";
    };

    ${systemConfig.user} = {
      home = "/home/${systemConfig.user}";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "${systemConfig.user}"
      ];
    };
  };

  system = {
    stateVersion = lib.mkDefault "25.11";
    activationScripts.fixVarRun = ''
      if [ -d /var/run ] && [ ! -L /var/run ]; then
        mv /var/run /var/run.bak
        ln -s /run /var/run
      fi
    '';
  };
}
