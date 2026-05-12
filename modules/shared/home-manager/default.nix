{
  pkgs,
  systemConfig,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    users.${systemConfig.user} =
      {
        ...
      }:
      {
        home = {
          username = systemConfig.user;
          enableNixpkgsReleaseCheck = false;
          stateVersion = "25.11";
          packages = with pkgs; [
            python3
            xz
            zlib
            nerd-fonts.jetbrains-mono
          ];
        };

        xdg.enable = true;
        fonts.fontconfig.enable = true;

        imports = [
          ./age
          ./docker
          ./dotnet
          ./git
          ./golang
          ./k8s
          ./nodejs
          ./shell.nix
          ./ssh
          ./tmux
        ];
      };
  };
}
