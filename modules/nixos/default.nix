{
  lib,
  systemConfig,
  pkgs,
  ...
}:
{
  imports = [
    ../shared
    ./docker.nix
    ./home-manager.nix
    ./tailscale.nix
    ./ssh.nix
    ./networking.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };
  };

  services.fail2ban.enable = true;
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
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjB/XELZ4R+nKj1MC6cNqextdFtiOo0bGvEiLMFOxO3 vm"
      ];
    };
  };

  environment.systemPackages = [
    pkgs.ghostty.terminfo
  ];

  system = {
    stateVersion = lib.mkDefault "25.11";
    activationScripts.fixVarRun = ''
      if [ -d /var/run ] && [ ! -L /var/run ]; then
        mv /var/run /var/run.bak
        ln -s /run /var/run
      fi
    '';
  };

  age.identityPaths = [ "/etc/ssh/vm_ed25519" ];
}
