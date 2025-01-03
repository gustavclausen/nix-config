{
  config,
  lib,
  homePath,
  currentSystemUser,
  ...
}:
with lib; let
  xdg_configHome = "${homePath}/.config";
  cfg = config.local.nvim;
in {
  options = {
    local.nvim.enable = mkOption {
      description = "Enable nvim local";
      default = true;
      example = true;
    };
  };

  config =
    mkIf cfg.enable
    {
      home-manager.users.${currentSystemUser} = {
        lib,
        config,
        ...
      }: {
        home = {
          activation.pullNvimConfig = lib.hm.dag.entryAfter ["installPackages"] ''
            PATH="${config.home.path}/bin:$PATH"

            REPOSRC="https://github.com/gustavclausen/nvim.config.git"
            LOCALREPO="${xdg_configHome}/nvim"

            LOCALREPO_VC_DIR="$LOCALREPO/.git"

            if [ ! -d "$LOCALREPO_VC_DIR" ]
            then
              git clone "$REPOSRC" "$LOCALREPO"
            else
              git -C "$LOCALREPO" pull
            fi
          '';
        };
      };
    };
}
