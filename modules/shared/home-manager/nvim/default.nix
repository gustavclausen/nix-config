{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options.custom.neovim = {
    enable = mkEnableOption "Custom Neovim installation";
  };

  config = let
    cfg = config.custom.neovim;
  in
    mkIf cfg.enable {
      home = {
        packages = with pkgs; [git openssh alejandra cargo lua tree-sitter shellcheck];
        file = {
          ".local/share/bin/clean-nvim" = {
            executable = true;
            text = ''
              #!/usr/bin/env zsh -e

              rm -rf ~/.cache/nvim
              rm -rf ~/.local/state/nvim
            '';
          };

          ".cargo/config" = {
            text = ''
              [net]
              git-fetch-with-cli = true
            '';
          };

          ".editorconfig" = {
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
        };

        activation.neovim = hm.dag.entryAfter ["installPackages"] ''
          export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"

          REPO_SRC="https://github.com/gustavclausen/nvim.config.git"
          LOCAL_PATH="$XDG_CONFIG_HOME/nvim"

          export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"

          if [ ! -d "$LOCAL_PATH/.git" ]
          then
            git clone "$REPO_SRC" "$LOCAL_PATH"
          else
            git -C "$LOCAL_PATH" pull
          fi
        '';
      };

      programs = {
        neovim = {
          enable = true;
          defaultEditor = true;
        };

        zsh.initExtra = lib.mkMerge [
          ''
            alias vim="nvim"
            alias n="nvim"
          ''
          (lib.mkIf (config.custom.tmux.enable) ''
            alias nvim="nvim --listen /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-\#{window_id}-\#{pane_id}' 2>/dev/null || echo 'main').pipe";
            alias vim="nvim --listen /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-\#{window_id}-\#{pane_id}' 2>/dev/null || echo 'main').pipe";
            alias n="nvim --listen /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-\#{window_id}-\#{pane_id}' 2>/dev/null || echo 'main').pipe";
          '')
        ];
      };
    };
}
