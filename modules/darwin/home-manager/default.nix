{
  systemConfig,
  ...
}:
{
  home-manager = {
    users.${systemConfig.user} =
      {
        pkgs,
        ...
      }:
      {
        home.packages = with pkgs; [
          darwin.trash
          reattach-to-user-namespace
        ];

        imports = [
          ./dock
        ];

        programs.zsh.initContent = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };
  };
}
