{
  currentSystemUser,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${currentSystemUser} =
      {
        ...
      }:
      {
        home = {
          username = currentSystemUser;
          homeDirectory = "/home/${currentSystemUser}";
        };

        xdg.enable = true;

        imports = [
          ../shared/home-manager
        ];

        fonts.fontconfig.enable = true;
      };
  };
}
