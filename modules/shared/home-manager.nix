{
  pkgs,
  lib,
  gitUser,
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
        nix-shell '<nixpkgs>' -A "$1"
      }

      alias ls='ls --color=auto'
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

      alias r=". ranger"
      alias vim="nvim"
      alias n="nvim"
      alias lg="lazygit"
      alias ks="switch"

      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        exec tmux attach || exec tmux
      fi

      GPG_TTY=$(tty)

      export GOPATH="$HOME/go"
      export PATH="$GOPATH:$HOME/go/bin:$PATH"

      source <(switch init zsh)
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
    userName = gitUser.userName;
    userEmail = gitUser.email;
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
      rebase.autoStash = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
      user.signingkey = "${gitUser.signingKey}";
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

    extraConfig = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          IdentityFile ~/.ssh/id_ed25519

          Host github.com
            Hostname github.com
            IdentitiesOnly yes
            IdentityFile ~/.ssh/id_github
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityFile ~/.ssh/id_ed25519

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
          set -g @dracula-show-powerline true
          set -g @dracula-plugins " "
          set -g @dracula-border-contrast true
          set -g @dracula-show-left-icon session
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-save-interval '5'
          set -g @continuum-restore 'on'
          set -g status-right 'Continuum status: #{continuum_status}'
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
}
