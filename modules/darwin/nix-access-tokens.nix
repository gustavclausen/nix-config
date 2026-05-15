{
  lib,
  config,
  systemConfig,
  ...
}:
let
  cfg = config.custom.darwin.nix-access-tokens;
in
{
  options.custom.darwin.nix-access-tokens = {
    enable = lib.mkEnableOption "Nix access tokens from an age secret";

    secretFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
      description = "Path to the age-encrypted file containing Nix access tokens.";
    };

    mode = lib.mkOption {
      type = lib.types.str;
      default = "0400";
      description = "File mode for the decrypted age secret.";
    };

    owner = lib.mkOption {
      type = lib.types.str;
      default = systemConfig.user;
      description = "Owner of the decrypted age secret.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "staff";
      description = "Group of the decrypted age secret.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretFile != null;
        message = "custom.darwin.nix-access-tokens.secretFile must be set when enabled.";
      }
    ];

    age.secrets.nix-access-tokens = {
      file = cfg.secretFile;
      inherit (cfg) mode owner group;
    };

    nix.extraOptions = ''
      include ${config.age.secrets.nix-access-tokens.path}
    '';
  };
}
