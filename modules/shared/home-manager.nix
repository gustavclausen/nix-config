{
  pkgs,
  lib,
  ...
}: {
  pyenv = {
    enable = true;
  };
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
          rev = "v0.7.0";
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

    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export PATH=$HOME/.local/share/bin:$PATH
      export PATH=$HOME/.local/scripts:$PATH

      export HISTIGNORE="pwd:ls:cd"

      shell() {
        nix-shell -p --command "bash ~/.local/share/bin/spawn-zsh" $@
      }

      alias ls='ls --color=auto'
      alias rp='source reload-path'
    '';

    initExtra = ''
      COMMON_COLORS_CURRENT_DIR=green

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

      export EDITOR=nvim

      alias r=". ranger"
      alias nvim="nvim --listen /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}').pipe"
      alias vim="nvim --listen /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}').pipe"
      alias n="nvim --listen /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}').pipe"
      alias lg="lazygit"
      alias ks="switch"
      alias ave="aws-vault exec"
      alias cdd="cd $HOME/dev"

      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        tmux new-session -A -s main
      fi

      GPG_TTY=$(tty)

      export GOPATH="$HOME/go"
      export PATH="$GOPATH:$HOME/go/bin:$PATH"

      setopt extendedglob
      if [[ -n $HOME/.secrets/*.env(#qN) ]]; then
        for file in $HOME/.secrets/*.env; do
            source "$file"
        done
      fi

      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="$(npm get prefix)/bin:$PATH"

      if command -v "switcher" >/dev/null 2>&1; then
        source <(switcher init zsh)
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
  };

  git = {
    enable = true;
    ignores = [
      ".idea"
      "*.DS_Store"
      ".vscode"
      ".terraform"
      "*.iml"
      "pyrightconfig.json"
      "*.swp"
    ];
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      pull.rebase = true;
      push.default = "current";
      rebase.autoStash = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };

  alacritty = {
    enable = true;
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
          background = "0x282a36";
          foreground = "0xf8f8f2";
        };
      };

      font = {
        size = 15.0;
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

    extraConfig = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          Host github.com
            Hostname github.com
            IdentitiesOnly yes
            IdentityFile ~/.ssh/id_github
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          Host github.com
            Hostname github.com
            IdentitiesOnly yes
            IdentityFile ~/.ssh/id_github
        '')
    ];
  };

  tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
          set -g @dracula-show-left-icon 🚀
          set -g @dracula-plugins " "
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '~/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-save-interval '5'
          set -g @continuum-restore 'on'
        '';
      }
    ];
    terminal = "xterm-256color";
    prefix = "C-a";
    escapeTime = 10;
    historyLimit = 10000;
    extraConfig = ''
      set-option -g focus-events on
      set-option -g pane-border-lines heavy
      set-option -g allow-rename off

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
    '';
  };

  lazygit = {
    enable = true;

    settings = {
      os = {
        edit = "nvim --server /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}').pipe --remote-send \"<cmd>lua require('core.scripts.lazygit-open-file')('{{filename}}', '{{line}}')<CR>\"";
        open = "nvim --server /tmp/nvim-server-$(tmux display-message -p '\#{session_id}-#{window_id}-#{pane_id}').pipe --remote-send \"<cmd>lua require('core.scripts.lazygit-open-file')('{{filename}}', '{{line}}')<CR>\"";
      };
      keybinding = {
        commits = {
          moveDownCommit = "<f1>";
          moveUpCommit = "<f2>";
        };
      };
    };
  };

  k9s = {
    enable = true;

    skins = {
      dracula = {
        foreground = "#f8f8f2";
        background = "#282a36";
        current_line = "#44475a";
        selection = "#44475a";
        comment = "#6272a4";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
        k9s = {
          body = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            logoColor = "#bd93f9";
          };
          prompt = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            suggestColor = "#bd93f9";
          };
          info = {
            fgColor = "#ff79c6";
            sectionColor = "#f8f8f2";
          };
          dialog = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            buttonFgColor = "#f8f8f2";
            buttonBgColor = "#bd93f9";
            buttonFocusFgColor = "#f1fa8c";
            buttonFocusBgColor = "#ff79c6";
            labelFgColor = "#ffb86c";
            fieldFgColor = "#f8f8f2";
          };
          frame = {
            border = {
              fgColor = "#44475a";
              focusColor = "#44475a";
            };
            menu = {
              fgColor = "#f8f8f2";
              keyColor = "#ff79c6";
              numKeyColor = "#ff79c6";
            };
            crumbs = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              activeColor = "#44475a";
            };
            status = {
              newColor = "#8be9fd";
              modifyColor = "#bd93f9";
              addColor = "#50fa7b";
              errorColor = "#ff5555";
              highlightColor = "#ffb86c";
              killColor = "#6272a4";
              completedColor = "#6272a4";
            };
            title = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              highlightColor = "#ffb86c";
              counterColor = "#bd93f9";
              filterColor = "#ff79c6";
            };
          };
          views = {
            charts = {
              bgColor = "default";
              defaultDialColors = ["#bd93f9" "#ff5555"];
              defaultChartColors = ["#bd93f9" "#ff5555"];
            };
            table = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              header = {
                fgColor = "#f8f8f2";
                bgColor = "#282a36";
                sorterColor = "#8be9fd";
              };
            };
            xray = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              cursorColor = "#44475a";
              graphicColor = "#bd93f9";
              showIcons = false;
            };
            yaml = {
              keyColor = "#ff79c6";
              colonColor = "#bd93f9";
              valueColor = "#f8f8f2";
            };
            logs = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              indicator = {
                fgColor = "#f8f8f2";
                bgColor = "#bd93f9";
                toggleOnColor = "#50fa7b";
                toggleOffColor = "#8be9fd";
              };
            };
          };
        };
      };
    };

    views = {
      views = {
        "v1/nodes" = {
          sortColumn = "AGE:desc";
          columns = ["NAME" "AGE" "STATUS" "TAINTS" "PODS" "LABELS" "%CPU" "%MEM"];
        };
      };
    };

    settings = {
      k9s = {
        ui = {
          skin = "dracula";
        };
      };
    };
  };

  fzf = {
    enable = true;
  };

  eza = {
    enable = true;
    icons = true;
  };
}
