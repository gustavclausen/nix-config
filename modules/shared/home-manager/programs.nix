{
  pkgs,
  lib,
  config,
  ...
}: {
  zsh = {
    enable = true;
    autocd = false;
    cdpath = ["~/.local/share/src"];
    dotDir = ".config/zsh";
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.1";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "v0.35.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
      {
        name = "zsh-z";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "afaf2965b41fdc6ca66066e09382726aa0b6aa04";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
      {
        name = "common";
        src = pkgs.fetchFromGitHub {
          owner = "jackharrisonsherlock";
          repo = "common";
          rev = "73c996a916e047d2bfb81d72def3620c55d258c5";
          sha256 = "mRtYtkYm5Yp3o+ADk8v4inM+miojaJV4KeVWDuiAOts=";
        };
        file = "common.zsh-theme";
      }
    ];

    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "z"
      ];
      extraConfig = ''
        DISABLE_AUTO_TITLE="true"
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737373"
      '';
    };

    initContent = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export PATH=$HOME/.local/share/bin:$PATH
      export PATH=$HOME/.local/scripts:$PATH

      export HISTIGNORE="pwd:ls:cd"

      alias ls='ls --color=auto'

      COMMON_COLORS_CURRENT_DIR=yellow
      COMMON_COLORS_RETURN_STATUS_TRUE=yellow
      COMMON_COLORS_RETURN_STATUS_FALSE=red
      COMMON_PROMPT_SYMBOL="|"

      ctx() {
        if [[ $AWS_VAULT ]]; then
          echo -n "%{$fg[$COMMON_COLORS_HOST_AWS_VAULT]%}$AWS_VAULT ❯%{$reset_color%} "
        fi

        if [[ (( $+commands[kubectl] )) ]]; then
          local current_ctx=$(kubectl config current-context 2> /dev/null)

          if [[ -n "$current_ctx" ]]; then
            echo -n "%{$fg[cyan]%}$current_ctx ❯%{$reset_color%} "
          fi
        fi
      }

      PROMPT='$(ctx)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'
      RPROMPT='$(common_git_status)'

      GPG_TTY=$(tty)

      setopt extendedglob
      if [[ -n $HOME/.secrets/*.env(#qN) ]]; then
        for file in $HOME/.secrets/*.env; do
            source "$file"
        done
      fi

      if [[ -n $HOME/.scripts/**/*.zsh(#qN) ]]; then
        for file in $HOME/.scripts/**/*.zsh; do
            source "$file"
        done

        script_dirs=($HOME/.scripts/**/)
        for script_dir in $script_dirs; do
          PATH="$script_dir:$PATH"
        done
      fi

      unsetopt extendedglob
    '';

    shellAliases = {
      lg = "lazygit";
      cdd = "cd $HOME/dev";
    };
  };

  alacritty = {
    settings = {
      colors = {
        bright = {
          black = "0x555555";
          blue = "0xcaa9fa";
          cyan = "0x8be9fd";
          green = "0x50fa7b";
          magenta = "0xff79c6";
          red = "0xff5555";
          white = "0xffffff";
          yellow = "0xf1fa8c";
        };

        normal = {
          black = "0x000000";
          blue = "0xbd93f9";
          cyan = "0x8be9fd";
          green = "0x50fa7b";
          magenta = "0xff79c6";
          red = "0xff5555";
          white = "0xbbbbbb";
          yellow = "0xf1fa8c";
        };

        primary = {
          background = "0x31363c";
          foreground = "0xf8f8f2";
        };
      };

      font = {
        size = 17.0;
        normal.family = "JetBrainsMono Nerd Font";
        normal.style = "Medium";
      };

      keyboard.bindings = [
        {
          chars = "\\u001Bj";
          key = "J";
          mods = "Alt";
        }
        {
          chars = "\\u001Bk";
          key = "K";
          mods = "Alt";
        }
        {
          chars = "\\u001Bh";
          key = "H";
          mods = "Alt";
        }
        {
          chars = "\\u001Bl";
          key = "L";
          mods = "Alt";
        }
        {
          chars = "\\u001BF";
          key = "Right";
          mods = "Alt";
        }
        {
          chars = "\\u001BB";
          key = "Left";
          mods = "Alt";
        }
      ];

      scrolling = {
        history = 20000;
        multiplier = 0;
      };

      window.startup_mode = "Maximized";
    };
  };

  ssh = {
    enable = true;

    includes = ["config.d/*"];
  };

  lazygit = {
    enable = true;

    settings = {
      os = lib.mkIf (config.custom.tmux.enable && config.custom.neovim.enable) {
        edit = "nvim --server /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}' 2>/dev/null || echo 'main').pipe --remote-send \"<cmd>lua require('scripts.lazygit-open-file')('{{filename}}')<CR>\"";
        editAtLine = "nvim --server /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}' 2>/dev/null || echo 'main').pipe --remote-send \"<cmd>lua require('scripts.lazygit-open-file')('{{filename}}', '{{line}}')<CR>\"";
        open = "nvim --server /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}' 2>/dev/null || echo 'main').pipe --remote-send \"<cmd>lua require('scripts.lazygit-open-file')('{{filename}}', '{{line}}')<CR>\"";
      };
      keybinding = {
        commits = {
          moveDownCommit = "<f1>";
          moveUpCommit = "<f2>";
        };
      };
    };
  };

  fzf = {
    enable = true;
  };

  eza = {
    enable = true;
    icons = "auto";
  };

  direnv = {
    enable = true;
    config = {
      global = {
        load_dotenv = true;
      };
    };
  };

  ripgrep = {
    enable = true;
  };

  jq = {
    enable = true;
  };

  gh = {
    enable = true;
  };

  fd = {
    enable = true;
  };
}
