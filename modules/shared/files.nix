{
  host,
  homePath,
  ...
}: let
  xdg_dataHome = "${homePath}/.local/share";
in {
  "${xdg_dataHome}/bin/nix-reload" = {
    executable = true;
    text = ''
      #!/usr/bin/env zsh -e

      cd ${homePath}/nix-config
      just switch ${host}

      echo "Reloading zsh shell..."
      exec zsh
    '';
  };
  "${xdg_dataHome}/bin/nix-rollback" = {
    executable = true;
    text = ''
      #!/usr/bin/env zsh -e

      cd ${homePath}/nix-config

      just rollback ${host}
    '';
  };
  "${xdg_dataHome}/bin/spawn-zsh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash -e

      echo $PATH > /tmp/path
      zsh
    '';
  };
  "${xdg_dataHome}/bin/reload-path" = {
    executable = true;
    text = ''
      #!/usr/bin/env zsh -e

      export PATH="$(cat /tmp/path):$PATH"
    '';
  };
  "${xdg_dataHome}/bin/clean-nvim" = {
    executable = true;
    text = ''
      #!/usr/bin/env zsh -e

      rm -rf ${homePath}/.cache/nvim
      rm -rf ${homePath}/.local/state/nvim
    '';
  };
  "${homePath}/.scripts/kubernetes/aws-vault-kubeswitch" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      set -e

      aws-vault export --format=json "$KUBESWITCH_AWS_PROFILE"
    '';
  };
  "${homePath}/.scripts/kubernetes/aws-vault-kubeswitch.zsh" = {
    executable = true;
    text = ''
      avswitch () {
        KUBESWITCH_AWS_PROFILE="$1"
        if [ -z $KUBESWITCH_AWS_PROFILE ]; then
          echo "AWS profile not passed as argument"
          return
        fi
        export KUBESWITCH_AWS_PROFILE

        AWS_REGION="$2"
        if [ -z $2 ]; then
          AWS_REGION=$(aws configure get region --profile $KUBESWITCH_AWS_PROFILE || aws configure get region --profile common)
        fi
        export AWS_REGION

        AWS_PROFILE=kube switch
      }
    '';
  };
  "${homePath}/.scripts/utils/tmux-navigator.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Based on: https://github.com/ThePrimeagen/.dotfiles/blob/602019e902634188ab06ea31251c01c1a43d1621/bin/.local/scripts/tmux-sessionizer

      set -e

      selected_dir=$(find "$HOME/dev" -mindepth 1 -maxdepth 1 -type d | fzf)

      if [[ -z $selected_dir ]]; then
        exit 0
      fi

      selected_dir_name=$(basename "$selected_dir" | tr . _)
      is_tmux_running=$(pgrep tmux)

      if [[ -z $TMUX ]] && [[ -z $is_tmux_running ]]; then
        echo "Script must be run in tmux environment"
        exit 1
      fi

      tmux new-window -n "$selected_dir_name" -c "$selected_dir"
    '';
  };

  "${homePath}/.editorconfig" = {
    text = ''
      root = true

      [*]
      indent_style = space
      indent_size = 2
      end_of_line = lf
      charset = utf-8
      trim_trailing_whitespace = true
      insert_final_newline = true

      [*.md]
      trim_trailing_whitespace = false

      [Makefile]
      indent_style = tab

      [{package.json}]
      indent_style = space
      indent_size = 2
    '';
  };
  "${homePath}/.cargo/config" = {
    text = ''
      [net]
      git-fetch-with-cli = true
    '';
  };
}
