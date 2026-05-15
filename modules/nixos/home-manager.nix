{
  systemConfig,
  ...
}:
{
  home-manager = {
    useUserPackages = true;
    users.${systemConfig.user} =
      {
        ...
      }:
      {
        home.homeDirectory = "/home/${systemConfig.user}";
      };
  };
}
