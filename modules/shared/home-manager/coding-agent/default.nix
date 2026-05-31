{
  lib,
  config,
  pkgs,
  agent-skills,
  superpowers,
  anthropic-skills,
  gustavclausen-skills,
  jeffallan-skills,
  ...
}:
let
  cfg = config.custom.coding-agent;

  mkAgentEnableOption =
    name:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install ${name} and sync skills for it.";
    };

  enabledAgentPackages =
    lib.optionals cfg.agents.claude-code.enable [ pkgs.claude-code ]
    ++ lib.optionals cfg.agents.codex.enable [ pkgs.codex ]
    ++ lib.optionals cfg.agents.opencode.enable [ pkgs.opencode ];

  enabledTargets = {
    claude = {
      enable = cfg.agents.claude-code.enable;
    };
    codex = {
      enable = cfg.agents.codex.enable;
    };
    opencode = {
      enable = cfg.agents.opencode.enable;
    };
  };
in
{
  imports = [
    agent-skills.homeManagerModules.default
  ];

  options.custom.coding-agent = {
    enable = lib.mkEnableOption "coding agent tools and shared skills";

    agents = {
      claude-code.enable = mkAgentEnableOption "Claude Code";
      codex.enable = mkAgentEnableOption "Codex";
      opencode.enable = mkAgentEnableOption "OpenCode";
    };

    skills = {
      enable = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Skill IDs to install into enabled coding agents.
        '';
        example = [
          "using-superpowers"
          "brainstorming"
          "frontend-design"
          "find-docs"
        ];
      };

      enableAll = lib.mkOption {
        type = lib.types.either lib.types.bool (lib.types.listOf lib.types.str);
        default = false;
        description = ''
          Enable all discovered skills. Set true for every source or use source names:
          superpowers, anthropic, context7.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = enabledAgentPackages ++ [
      pkgs.ctx7
    ];

    programs.agent-skills = {
      enable = true;

      sources = {
        superpowers = {
          path = superpowers;
          subdir = "skills";
        };

        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };

        gustavclausen = {
          path = gustavclausen-skills;
          subdir = "skills";
        };

        jeffallan = {
          path = jeffallan-skills;
          subdir = "skills";
        };
      };

      skills = {
        enable = cfg.skills.enable;
        enableAll = cfg.skills.enableAll;
      };

      targets = enabledTargets;
    };
  };
}
