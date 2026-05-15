{
  systemConfig,
  ...
}:
{
  home-manager = {
    users.${systemConfig.user} =
      {
        pkgs,
        config,
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

        age = {
          identityPaths = [
            "${config.home.homeDirectory}/.ssh/id_ed25519"
          ];
          secretsDir = "${config.home.homeDirectory}/.agenix/agenix";
          secretsMountPoint = "${config.home.homeDirectory}/.agenix/agenix.d";
        };

        programs.zsh.initContent = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };
  };
}
