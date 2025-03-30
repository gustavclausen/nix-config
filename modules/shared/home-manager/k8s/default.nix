{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.k8s;
in
  with lib; {
    options.custom.k8s = {
      enable = mkEnableOption "Kubernetes tools";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        kind
        krew
        kubectl
        kubeswitch
        kustomize
        helm-docs
        helmfile
      ];

      programs = {
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

        zsh.initExtra = ''
          if command -v "switcher" >/dev/null 2>&1; then
            source <(switcher init zsh)
          fi

          export PATH="$HOME/.krew/bin:$PATH"
        '';
      };
    };
  }
