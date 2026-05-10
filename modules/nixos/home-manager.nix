{
  currentSystemUser,
  host,
  inputs,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${currentSystemUser} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          username = currentSystemUser;
          homeDirectory = "/home/${currentSystemUser}";
        };

        xdg.enable = true;

        imports = [
          (import ../shared/home-manager {
            inherit
              pkgs
              inputs
              host
              lib
              config
              ;
          })
        ];

        fonts.fontconfig.enable = true;
      };
  };
}
