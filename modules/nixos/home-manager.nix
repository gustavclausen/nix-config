{
  systemConfig,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${systemConfig.user} =
      {
        ...
      }:
      {
        home = {
          username = systemConfig.user;
          homeDirectory = "/home/${systemConfig.user}";
        };

        xdg.enable = true;

        imports = [
          ../shared/home-manager
        ];

        fonts.fontconfig.enable = true;
      };
  };
}
