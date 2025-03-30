{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; {
  options.custom.tmux = {
    enable = mkEnableOption "Tmux configuration";
  };

  config = let
    cfg = config.custom.tmux;
  in
    mkIf cfg.enable {
      home = {
        file = {
          ".scripts/utils/tmux-navigator.sh" = {
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
        };
      };

      programs = {
        tmux = {
          enable = true;
          plugins = with pkgs; [
            tmuxPlugins.vim-tmux-navigator
            {
              plugin = inputs.minimal-tmux.packages.x86_64-darwin.default;
              extraConfig = ''
                set -g @minimal-tmux-indicator-str "🔒"
                set -g @minimal-tmux-bg "#effa87"
                set -g @minimal-tmux-right false
              '';
            }
          ];
          terminal = "screen-256color";
          prefix = "C-a";
          escapeTime = 10;
          historyLimit = 10000;
          shell = "${pkgs.zsh}/bin/zsh";
          extraConfig = ''
            set-option -a terminal-features 'xterm-256color:RGB'

            set-option -g focus-events on
            set-option -g pane-border-lines heavy
            set -g pane-active-border-style fg=color228
            set -g pane-border-style fg=grey
            set-option -g allow-rename off
            set-option -g renumber-windows on

            setw -g mode-keys vi
            bind 'v' copy-mode

            bind C-v split-window -c "#{pane_current_path}" -h
            bind C-x split-window -c "#{pane_current_path}" -v
            unbind '"'
            unbind %

            bind c new-window -c "#{pane_current_path}"

            bind -r M-k resize-pane -U 5
            bind -r M-j resize-pane -D 5
            bind -r M-h resize-pane -L 5
            bind -r M-l resize-pane -R 5

            bind -r N display-popup -E "~/.scripts/utils/tmux-navigator.sh"
            bind r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux config is reloaded"

            set-option -g default-command ${pkgs.zsh}/bin/zsh
          '';
        };

        zsh.initExtra = ''
          if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
            tmux new-session -A -s main
          fi
        '';
      };
    };
}
