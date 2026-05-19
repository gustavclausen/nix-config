{
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}:
let
  cfg = config.custom.serverProfile;
in
with lib;
{
  options.custom.serverProfile = {
    enable = mkEnableOption "Server VM profile";

    coolifyAccess = mkEnableOption "Coolify root SSH access";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.fail2ban.enable = true;

      users.users.${systemConfig.user}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjB/XELZ4R+nKj1MC6cNqextdFtiOo0bGvEiLMFOxO3 vm"
      ];

      environment.systemPackages = [
        pkgs.ghostty.terminfo
      ];

      age.identityPaths = [ "/etc/ssh/vm_ed25519" ];

      services.openssh = {
        enable = true;
        openFirewall = false;

        settings = {
          # Security hardening
          PasswordAuthentication = false;
          PermitRootLogin = "prohibit-password";
          KbdInteractiveAuthentication = false;

          UseDns = false; # Performance

          PubkeyAuthentication = true;
        };

        extraConfig = ''
          ClientAliveInterval 60
          ClientAliveCountMax 3
        '';
      };

      networking = {
        hostName = lib.mkDefault systemConfig.name;
        networkmanager.enable = true;
        nftables.enable = true;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 22 ];
        };
      };
    })

    (mkIf cfg.coolifyAccess {
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDR9Mj2ImPIQvXU3woymg+86e0wlquOPu6cfrNGhwug root@coolify"
      ];
    })
  ];
}
