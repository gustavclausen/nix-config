{
  lib,
  config,
  ...
}: let
  cfg = config.custom.ssh;
in
  with lib; {
    options.custom.ssh = {
      enable = mkEnableOption "SSH configuration management";

      keys = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Custom name for the SSH key files (e.g., 'github_key')";
            };
            publicKey = mkOption {
              type = types.str;
              description = "Public SSH key content";
            };
            privateKeyPath = mkOption {
              type = types.str;
              description = "Path to private SSH key (typically config.age.secrets.\"<name>\".path)";
            };
          };
        });
        default = {};
        description = "SSH keys to manage. Attribute name is a unique identifier for the key.";
      };

      hosts = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            hostname = mkOption {
              type = types.str;
              description = "Server hostname or IP address";
            };
            user = mkOption {
              type = types.str;
              description = "SSH username";
            };
            port = mkOption {
              type = types.int;
              default = 22;
              description = "SSH port";
            };
            keyName = mkOption {
              type = types.str;
              description = "Reference to key ID defined in custom.ssh.keys";
            };
          };
        });
        default = {};
        description = "SSH host configurations. Attribute name becomes the SSH Host alias.";
      };
    };

    config = let
      sshHome = "${config.home.homeDirectory}/.ssh";

      # Generate private key symlinks
      sshKeyFiles =
        lib.mapAttrs' (keyId: keyConfig: {
          name = "${sshHome}/${keyConfig.name}";
          value = {
            source = config.lib.file.mkOutOfStoreSymlink keyConfig.privateKeyPath;
          };
        })
        cfg.keys;

      # Generate public key files
      sshPublicKeyFiles =
        lib.mapAttrs' (keyId: keyConfig: {
          name = "${sshHome}/${keyConfig.name}.pub";
          value = {
            text = keyConfig.publicKey;
          };
        })
        cfg.keys;

      # Generate host config files
      sshHostConfigs =
        lib.mapAttrs' (
          hostAlias: hostConfig: let
            keyConfig = cfg.keys.${hostConfig.keyName};
            keyPath = "${sshHome}/${keyConfig.name}";
          in {
            name = "${sshHome}/config.d/${hostAlias}";
            value = {
              text = ''
                Host ${hostAlias}
                  HostName ${hostConfig.hostname}
                  User ${hostConfig.user}
                  Port ${toString hostConfig.port}
                  IdentityFile ${keyPath}
              '';
            };
          }
        )
        cfg.hosts;
    in
      mkIf cfg.enable {
        assertions = lib.mkMerge [
          # Validate referenced keys exist
          (lib.mapAttrsToList (hostAlias: hostConfig: {
              assertion = cfg.keys ? ${hostConfig.keyName};
              message = "custom.ssh.hosts.${hostAlias}.keyName references '${hostConfig.keyName}', but this key is not defined in custom.ssh.keys";
            })
            cfg.hosts)

          # Validate key fields are non-empty
          (lib.flatten (lib.mapAttrsToList (keyId: keyConfig: [
              {
                assertion = keyConfig.publicKey != "";
                message = "custom.ssh.keys.${keyId}.publicKey must be set";
              }
              {
                assertion = keyConfig.privateKeyPath != "";
                message = "custom.ssh.keys.${keyId}.privateKeyPath must be set";
              }
              {
                assertion = keyConfig.name != "";
                message = "custom.ssh.keys.${keyId}.name must be set";
              }
            ])
            cfg.keys))

          # Validate no duplicate key names
          (let
            keyNames = lib.mapAttrsToList (_: v: v.name) cfg.keys;
            uniqueNames = lib.unique keyNames;
          in [
            {
              assertion = (builtins.length keyNames) == (builtins.length uniqueNames);
              message = "custom.ssh.keys contains duplicate names. Each key must have a unique name.";
            }
          ])
        ];

        home.file = sshKeyFiles // sshPublicKeyFiles // sshHostConfigs;
      };
  }
