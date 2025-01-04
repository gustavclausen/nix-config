{
  config,
  lib,
  homePath,
  currentSystemUser,
  ...
}:
with lib; let
  scriptsHome = "${homePath}/.scripts";
  cfg = config.local.zn-scripts;
in {
  options = {
    local.zn-scripts.enable = mkOption {
      description = "Enable zn-scripts";
      default = false;
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
          activation.pullZNScripts = lib.hm.dag.entryAfter ["installPackages"] ''
            PATH="${config.home.path}/bin:$PATH"

            REPOSRC="https://github.com/gustavclausen/zn-scripts.git"
            LOCALREPO="${scriptsHome}/zn-scripts"

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
