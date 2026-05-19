{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.coolifyProxy;

  stateUser = toString cfg.stateUser;
  stateGroup = toString cfg.stateGroup;

  domainLabels = [
    "--label=traefik.enable=true"
    "--label=traefik.http.routers.traefik.entrypoints=http"
    "--label=traefik.http.routers.traefik.service=api@internal"
    "--label=traefik.http.services.traefik.loadbalancer.server.port=8080"
    "--label=traefik.http.routers.traefik.tls=true"
    "--label=traefik.http.routers.traefik.tls.certresolver=${cfg.certResolver}"
  ]
  ++ lib.flatten (
    lib.imap0 (
      index: domain:
      [
        "--label=traefik.http.routers.traefik.tls.domains[${toString index}].main=${domain.main}"
      ]
      ++ lib.optionals (domain.sans != [ ]) [
        "--label=traefik.http.routers.traefik.tls.domains[${toString index}].sans=${lib.concatStringsSep "," domain.sans}"
      ]
    ) cfg.domains
  );
in
{
  options.services.coolifyProxy = {
    enable = lib.mkEnableOption "Coolify Traefik proxy with NixOS-managed Docker container";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/data/coolify/proxy";
      description = "Persistent Traefik state directory.";
    };

    networkName = lib.mkOption {
      type = lib.types.str;
      default = "coolify";
      description = "Docker network used by the proxy container.";
    };

    stateUser = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 9999;
      description = "Numeric UID that owns proxy state files.";
    };

    stateGroup = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 9999;
      description = "Numeric GID that owns proxy state files.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "traefik:v3.7.1";
      description = "Traefik proxy image.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.stateDir}/.env";
      description = "Path to the .env file for Traefik DNS challenge credentials.";
    };

    certResolver = lib.mkOption {
      type = lib.types.str;
      default = "letsencrypt";
      description = "Traefik certificate resolver.";
    };

    domains = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            main = lib.mkOption {
              type = lib.types.str;
              description = "Primary TLS domain.";
            };

            sans = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "TLS subject alternative names.";
            };
          };
        }
      );
      default = [ ];
      description = "TLS domains for Traefik.";
    };

    dnsProvider = lib.mkOption {
      type = lib.types.str;
      default = "hetzner";
      description = "Traefik ACME DNS challenge provider.";
    };

    dnsResolvers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1:53"
        "8.8.8.8:53"
      ];
      description = "Recursive DNS resolvers Traefik uses for ACME DNS challenge checks.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "services.coolifyProxy requires virtualisation.docker.enable = true;";
      }
      {
        assertion = config.virtualisation.oci-containers.backend == "docker";
        message = "services.coolifyProxy requires virtualisation.oci-containers.backend = \"docker\";";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/dynamic 0750 ${stateUser} ${stateGroup} -"
      "f ${cfg.stateDir}/acme.json 0600 ${stateUser} ${stateGroup} -"
    ];

    systemd.services = {
      coolify-proxy-prepare-state = {
        description = "Prepare Coolify proxy state directories";
        wantedBy = [ "multi-user.target" ];
        before = [ "docker-coolify-proxy.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          RequiresMountsFor = [ cfg.stateDir ];
        };
        script = ''
          set -eu

          install -d -m 0750 -o ${stateUser} -g ${stateGroup} \
            ${lib.escapeShellArg cfg.stateDir} \
            ${lib.escapeShellArg "${cfg.stateDir}/dynamic"}

          if [ ! -e ${lib.escapeShellArg "${cfg.stateDir}/acme.json"} ]; then
            install -m 0600 -o ${stateUser} -g ${stateGroup} /dev/null ${lib.escapeShellArg "${cfg.stateDir}/acme.json"}
          else
            chown ${stateUser}:${stateGroup} ${lib.escapeShellArg "${cfg.stateDir}/acme.json"}
            chmod 0600 ${lib.escapeShellArg "${cfg.stateDir}/acme.json"}
          fi
        '';
      };

      coolify-proxy-network = {
        description = "Create the Coolify proxy Docker network";
        wantedBy = [ "multi-user.target" ];
        before = [ "docker-coolify-proxy.service" ];
        after = [
          "docker.service"
          "coolify-proxy-prepare-state.service"
        ];
        requires = [
          "docker.service"
          "coolify-proxy-prepare-state.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          if ! ${pkgs.docker}/bin/docker network inspect ${lib.escapeShellArg cfg.networkName} >/dev/null 2>&1; then
            ${pkgs.docker}/bin/docker network create --attachable ${lib.escapeShellArg cfg.networkName}
          fi
        '';
      };

      docker-coolify-proxy = {
        after = [
          "coolify-proxy-network.service"
          "coolify-proxy-prepare-state.service"
        ];
        requires = [
          "coolify-proxy-network.service"
          "coolify-proxy-prepare-state.service"
        ];
      };
    };

    virtualisation.oci-containers.containers.coolify-proxy = {
      image = cfg.image;
      autoStart = true;
      environmentFiles = [ cfg.environmentFile ];
      ports = [
        "443:443"
        "443:443/udp"
        "8080"
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${cfg.stateDir}:/traefik"
      ];
      cmd = [
        "--ping=true"
        "--ping.entrypoint=http"
        "--api.dashboard=true"
        "--entrypoints.http.address=:80"
        "--entrypoints.https.address=:443"
        "--entrypoints.http.http.encodequerysemicolons=true"
        "--entryPoints.http.http2.maxConcurrentStreams=250"
        "--entrypoints.https.http.encodequerysemicolons=true"
        "--entryPoints.https.http2.maxConcurrentStreams=250"
        "--entrypoints.https.http3"
        "--providers.file.directory=/traefik/dynamic/"
        "--providers.file.watch=true"
        "--certificatesresolvers.${cfg.certResolver}.acme.dnschallenge.provider=${cfg.dnsProvider}"
        "--certificatesresolvers.${cfg.certResolver}.acme.dnschallenge.delaybeforecheck=0"
      ]
      ++ lib.optionals (cfg.dnsResolvers != [ ]) [
        "--certificatesresolvers.${cfg.certResolver}.acme.dnschallenge.resolvers=${lib.concatStringsSep "," cfg.dnsResolvers}"
      ]
      ++ [
        "--certificatesresolvers.${cfg.certResolver}.acme.storage=/traefik/acme.json"
        "--api.insecure=false"
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
      ];
      extraOptions = [
        "--network=${cfg.networkName}"
        "--add-host=host.docker.internal:host-gateway"
        "--pull=always"
        "--health-cmd=wget -qO- http://localhost:80/ping || exit 1"
        "--health-interval=4s"
        "--health-timeout=2s"
        "--health-retries=5"
        "--label=coolify.proxy=true"
      ]
      ++ domainLabels;
    };
  };
}
