{
  config,
  pkgs,
  lib,
  currentSystemUser,
  ...
}:
with lib; let
  home = "${config.users.users.${currentSystemUser}.home}";
  xdg_configHome = "${home}/.config";
  cfg = config.local.nvim;
  inherit (pkgs) git;
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
      system.activationScripts.postUserActivation.text = ''
        git_cmd="${git}/bin/git"

        REPOSRC="https://github.com/gustavclausen/nvim.config.git"
        LOCALREPO="${xdg_configHome}/nvim"

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
