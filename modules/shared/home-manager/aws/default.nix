{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.aws;
in
  with lib; {
    options.custom.aws = {
      enable = mkEnableOption "AWS config";

      configPath = mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to aws config file";
      };
    };

    config = mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          aws-vault
          awscli2
          eksctl
        ];

        file = {
          ".aws/config" = lib.mkIf (cfg.configPath != null) {
            source = config.lib.file.mkOutOfStoreSymlink cfg.configPath;
          };

          ".scripts/kubernetes/aws-vault-kubeswitch" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash

              set -e

              aws-vault export --format=json "$KUBESWITCH_AWS_PROFILE"
            '';
          };

          ".scripts/kubernetes/aws-vault-kubeswitch.zsh" = {
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
        };
      };

      programs.zsh.initContent = ''
        alias ave="aws-vault exec"
      '';
    };
  }
