{
  currentSystemUser,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    users.${currentSystemUser} =
      {
        pkgs,
        ...
      }:
      {
        xdg.enable = true;
        home = {
          packages = import ./packages.nix { inherit pkgs; };
        };
        imports = [
          ./dock
          ../../shared/home-manager
        ];
        fonts.fontconfig.enable = true;
        programs.zsh.initContent = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };
  };
}
