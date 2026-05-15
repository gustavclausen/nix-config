{ systemConfig, lib, ... }:
{
  networking = {
    hostName = lib.mkDefault systemConfig.name;
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
    };
  };
}
