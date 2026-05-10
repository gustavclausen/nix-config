{
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  networking = {
    hostName = "coolify";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk";

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  disko.devices.disk.main = {
    device = "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "512M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  system.stateVersion = "25.11";
}
