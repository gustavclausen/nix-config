{
  config,
  pkgs,
  lib,
  homePath,
  ...
}:
with lib; let
  scriptsHome = "${homePath}/.scripts";
  cfg = config.local.zn-scripts;
  inherit (pkgs) git;
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
      system.activationScripts.postUserActivation.text = ''
        git_cmd="${git}/bin/git"

        REPOSRC="https://github.com/gustavclausen/zn-scripts.git"
        LOCALREPO="${scriptsHome}/zn-scripts"

        LOCALREPO_VC_DIR="$LOCALREPO/.git"

        if [ ! -d "$LOCALREPO_VC_DIR" ]
        then
        	$git_cmd clone "$REPOSRC" "$LOCALREPO"
        else
        	$git_cmd -C "$LOCALREPO" pull
        fi
      '';
    };
}
