{host, ...}: let
  xdg_dataHome = ".local/share";
in {
  "${xdg_dataHome}/bin/nix-reload" = {
    executable = true;
    text = ''
      #!/usr/bin/env zsh -e

      cd ~/nix-config
      just switch ${host}

      echo "Reloading zsh shell..."
      exec zsh
    '';
  };
  "${xdg_dataHome}/bin/nix-rollback" = {
    executable = true;
    text = ''
      #!/usr/bin/env zsh -e

      cd ~/nix-config

      just rollback ${host}
    '';
  };
}
