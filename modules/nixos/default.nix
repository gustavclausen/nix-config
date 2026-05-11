{
  lib,
  systemConfig,
  ...
}:
{
  networking.hostName = lib.mkDefault systemConfig.name;

  imports = [
    ../shared
    ./home-manager.nix
  ];

  users.users.${systemConfig.user} = {
    home = "/home/${systemConfig.user}";
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
  };

  virtualisation.docker.enable = true;

  system.stateVersion = lib.mkDefault "25.11";
}
