{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.coolify;

  containerNames = [
    "coolify"
    "coolify-db"
    "coolify-redis"
    "coolify-realtime"
    "coolify-proxy"
  ];

  containerUnits = map (name: "docker-${name}") containerNames;
  containerServices = map (unit: "${unit}.service") containerUnits;

  stateUser = toString cfg.stateUser;
  stateGroup = toString cfg.stateGroup;

  domainLabels = [
    "--label=traefik.enable=true"
    "--label=traefik.http.routers.traefik.entrypoints=http"
    "--label=traefik.http.routers.traefik.service=api@internal"
    "--label=traefik.http.services.traefik.loadbalancer.server.port=8080"
    "--label=traefik.http.routers.traefik.tls=true"
    "--label=traefik.http.routers.traefik.tls.certresolver=${cfg.proxy.certResolver}"
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
    ) cfg.proxy.domains
  );
in
{
  options.services.coolify = {
    enable = lib.mkEnableOption "Coolify with NixOS-managed Docker containers";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/data/coolify";
      description = "Persistent state directory";
    };

    appPort = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Host port";
    };

    soketiPort = lib.mkOption {
      type = lib.types.port;
      default = 6001;
      description = "Host port for realtime websocket traffic";
    };

    networkName = lib.mkOption {
      type = lib.types.str;
      default = "coolify";
      description = "Docker network used by the containers";
    };

    stateUser = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 9999;
      description = "Numeric UID that owns state files";
    };

    stateGroup = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 9999;
      description = "Numeric GID that owns state files";
    };

    images = {
      coolify = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io/coollabsio/coolify:4.0.0";
        description = "Coolify application image";
      };

      postgres = lib.mkOption {
        type = lib.types.str;
        default = "postgres:18.4-alpine";
        description = "PostgreSQL image";
      };

      redis = lib.mkOption {
        type = lib.types.str;
        default = "redis:8.6.3-alpine";
        description = "Redis image";
      };

      realtime = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io/coollabsio/coolify-realtime:1.0.13";
        description = "Coolify realtime image";
      };

      proxy = lib.mkOption {
        type = lib.types.str;
        default = "traefik:v3.7.1";
        description = "Traefik proxy image";
      };
    };

    secrets = {
      environmentFile = lib.mkOption {
        type = lib.types.str;
        default = "${cfg.stateDir}/source/.env";
        description = "Path to .env file for Coolify";
      };

      proxyEnvironmentFile = lib.mkOption {
        type = lib.types.str;
        default = "${cfg.stateDir}/proxy/.env";
        description = "Path to the .env file for traefik";
      };

      sshKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "${cfg.stateDir}/ssh/keys/id.root@host.docker.internal";
        description = "Path to the SSH key file for Coolify";
      };
    };

    proxy = {
      certResolver = lib.mkOption {
        type = lib.types.str;
        default = "letsencrypt";
        description = "Traefik certificate resolver";
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
        description = "TLS domains for the Traefik";
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
        description = "Recursive DNS resolvers Traefik uses for ACME DNS challenge checks";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "services.coolify requires virtualisation.docker.enable = true;";
      }
      {
        assertion = config.virtualisation.oci-containers.backend == "docker";
        message = "services.coolify requires virtualisation.oci-containers.backend = \"docker\";";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/source 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/ssh 0700 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/ssh/keys 0700 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/ssh/mux 0700 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/applications 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/databases 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/backups 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/services 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/webhooks-during-maintenance 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/proxy 0750 ${stateUser} ${stateGroup} -"
      "d ${cfg.stateDir}/proxy/dynamic 0750 ${stateUser} ${stateGroup} -"
      "f ${cfg.stateDir}/proxy/acme.json 0600 ${stateUser} ${stateGroup} -"
    ];

    systemd.services = lib.mkMerge [
      {
        coolify-prepare-state = {
          description = "Prepare Coolify state directories";
          wantedBy = [ "multi-user.target" ];
          before = containerServices ++ [ "coolify-prepare-env.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            RequiresMountsFor = [ cfg.stateDir ];
          };
          script = ''
            set -eu

            install -d -m 0750 -o ${stateUser} -g ${stateGroup} \
              ${lib.escapeShellArg cfg.stateDir} \
              ${lib.escapeShellArg "${cfg.stateDir}/source"} \
              ${lib.escapeShellArg "${cfg.stateDir}/applications"} \
              ${lib.escapeShellArg "${cfg.stateDir}/databases"} \
              ${lib.escapeShellArg "${cfg.stateDir}/backups"} \
              ${lib.escapeShellArg "${cfg.stateDir}/services"} \
              ${lib.escapeShellArg "${cfg.stateDir}/webhooks-during-maintenance"} \
              ${lib.escapeShellArg "${cfg.stateDir}/proxy"} \
              ${lib.escapeShellArg "${cfg.stateDir}/proxy/dynamic"}

            install -d -m 0700 -o ${stateUser} -g ${stateGroup} \
              ${lib.escapeShellArg "${cfg.stateDir}/ssh"} \
              ${lib.escapeShellArg "${cfg.stateDir}/ssh/keys"} \
              ${lib.escapeShellArg "${cfg.stateDir}/ssh/mux"}

            ssh_key_source=${lib.escapeShellArg cfg.secrets.sshKeyFile}
            ssh_key_target=${lib.escapeShellArg "${cfg.stateDir}/ssh/keys/id.root@host.docker.internal"}

            if [ ! -e "$ssh_key_source" ]; then
              echo "Coolify SSH key file not found: $ssh_key_source" >&2
              exit 1
            fi

            if [ "$ssh_key_source" != "$ssh_key_target" ]; then
              install -m 0600 -o ${stateUser} -g ${stateGroup} "$ssh_key_source" "$ssh_key_target"
            else
              chown ${stateUser}:${stateGroup} "$ssh_key_target"
              chmod 0600 "$ssh_key_target"
            fi

            if [ ! -e ${lib.escapeShellArg "${cfg.stateDir}/proxy/acme.json"} ]; then
              install -m 0600 -o ${stateUser} -g ${stateGroup} /dev/null ${lib.escapeShellArg "${cfg.stateDir}/proxy/acme.json"}
            else
              chown ${stateUser}:${stateGroup} ${lib.escapeShellArg "${cfg.stateDir}/proxy/acme.json"}
              chmod 0600 ${lib.escapeShellArg "${cfg.stateDir}/proxy/acme.json"}
            fi
          '';
        };

        coolify-network = {
          description = "Create the Coolify Docker network";
          wantedBy = [ "multi-user.target" ];
          before = containerServices;
          after = [
            "docker.service"
            "coolify-prepare-state.service"
          ];
          requires = [
            "docker.service"
            "coolify-prepare-state.service"
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

        coolify-prepare-env = {
          description = "Prepare derived environment files for Coolify containers";
          wantedBy = [ "multi-user.target" ];
          after = [ "coolify-prepare-state.service" ];
          requires = [ "coolify-prepare-state.service" ];
          before = [
            "docker-coolify-db.service"
            "docker-coolify-realtime.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -eu

            source_env="${cfg.secrets.environmentFile}"
            runtime_dir="/run/coolify"

            install -d -m 0700 -o root -g root "$runtime_dir"

            get_env() {
              ${pkgs.gawk}/bin/awk -v key="$1" '
                BEGIN { FS = "=" }
                $0 ~ /^[[:space:]]*#/ { next }
                $1 == key {
                  sub(/^[^=]*=/, "")
                  print
                  exit
                }
              ' "$source_env"
            }

            db_username="$(get_env DB_USERNAME)"
            db_password="$(get_env DB_PASSWORD)"
            db_database="$(get_env DB_DATABASE)"
            pusher_app_id="$(get_env PUSHER_APP_ID)"
            pusher_app_key="$(get_env PUSHER_APP_KEY)"
            pusher_app_secret="$(get_env PUSHER_APP_SECRET)"

            if [ -z "$db_database" ]; then
              db_database="coolify"
            fi

            umask 077
            {
              printf 'POSTGRES_USER=%s\n' "$db_username"
              printf 'POSTGRES_PASSWORD=%s\n' "$db_password"
              printf 'POSTGRES_DB=%s\n' "$db_database"
            } > "$runtime_dir/postgres.env"

            {
              printf 'APP_NAME=Coolify\n'
              printf 'SOKETI_DEBUG=false\n'
              printf 'SOKETI_DEFAULT_APP_ID=%s\n' "$pusher_app_id"
              printf 'SOKETI_DEFAULT_APP_KEY=%s\n' "$pusher_app_key"
              printf 'SOKETI_DEFAULT_APP_SECRET=%s\n' "$pusher_app_secret"
            } > "$runtime_dir/soketi.env"
          '';
        };

        coolify-wait-dependencies = {
          description = "Wait for Coolify dependency containers";
          before = [ "docker-coolify.service" ];
          after = [
            "docker-coolify-db.service"
            "docker-coolify-redis.service"
            "docker-coolify-realtime.service"
          ];
          requires = [
            "docker-coolify-db.service"
            "docker-coolify-redis.service"
            "docker-coolify-realtime.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -eu

            wait_healthy() {
              name="$1"
              timeout="$2"
              elapsed=0

              while [ "$elapsed" -lt "$timeout" ]; do
                status="$(${pkgs.docker}/bin/docker inspect --format '{{ if .State.Health }}{{ .State.Health.Status }}{{ else }}{{ .State.Status }}{{ end }}' "$name" 2>/dev/null || true)"
                if [ "$status" = "healthy" ]; then
                  return 0
                fi

                sleep 2
                elapsed=$((elapsed + 2))
              done

              echo "Timed out waiting for $name to become healthy"
              ${pkgs.docker}/bin/docker inspect "$name" || true
              ${pkgs.docker}/bin/docker logs --tail=100 "$name" || true
              return 1
            }

            wait_healthy coolify-db 120
            wait_healthy coolify-redis 120
            wait_healthy coolify-realtime 120
          '';
        };

        docker-coolify = {
          after = [
            "coolify-wait-dependencies.service"
          ];
          requires = [ "coolify-wait-dependencies.service" ];
          wants = [
            "docker-coolify-db.service"
            "docker-coolify-redis.service"
            "docker-coolify-realtime.service"
          ];
        };
      }
      (lib.genAttrs containerUnits (_: {
        after = [
          "coolify-network.service"
          "coolify-prepare-state.service"
        ];
        requires = [
          "coolify-network.service"
          "coolify-prepare-state.service"
        ];
      }))
      (lib.genAttrs
        [
          "docker-coolify-db"
          "docker-coolify-realtime"
        ]
        (_: {
          after = [ "coolify-prepare-env.service" ];
          requires = [ "coolify-prepare-env.service" ];
        })
      )
    ];

    virtualisation.oci-containers.containers = {
      coolify = {
        image = cfg.images.coolify;
        autoStart = true;
        environmentFiles = [ cfg.secrets.environmentFile ];
        environment = {
          APP_ENV = "production";
          APP_NAME = "Coolify";
          APP_PORT = toString cfg.appPort;
          AUTOUPDATE = "false";
          DOCKER_ADDRESS_POOL_BASE = "172.17.0.0/16";
          PHP_MEMORY_LIMIT = "256M";
          PHP_FPM_PM_CONTROL = "dynamic";
          PHP_FPM_PM_START_SERVERS = "1";
          PHP_FPM_PM_MIN_SPARE_SERVERS = "1";
          PHP_FPM_PM_MAX_SPARE_SERVERS = "10";
        };
        ports = [ "${toString cfg.appPort}:8080" ];
        volumes = [
          "${cfg.secrets.environmentFile}:/var/www/html/.env:ro"
          "${cfg.stateDir}/ssh:/var/www/html/storage/app/ssh"
          "${cfg.stateDir}/applications:/var/www/html/storage/app/applications"
          "${cfg.stateDir}/databases:/var/www/html/storage/app/databases"
          "${cfg.stateDir}/services:/var/www/html/storage/app/services"
          "${cfg.stateDir}/backups:/var/www/html/storage/app/backups"
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        extraOptions = [
          "--network=${cfg.networkName}"
          "--add-host=host.docker.internal:host-gateway"
          "--pull=always"
          "--health-cmd=curl --fail http://127.0.0.1:8080/api/health || exit 1"
          "--health-interval=5s"
          "--health-retries=10"
          "--health-timeout=2s"
        ];
      };

      coolify-db = {
        image = cfg.images.postgres;
        autoStart = true;
        environmentFiles = [ "/run/coolify/postgres.env" ];
        volumes = [ "coolify-db:/var/lib/postgresql" ];
        extraOptions = [
          "--network=${cfg.networkName}"
          "--network-alias=coolify-db"
          "--pull=always"
          ''--health-cmd=pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"''
          "--health-interval=5s"
          "--health-retries=10"
          "--health-timeout=2s"
        ];
      };

      coolify-redis = {
        image = cfg.images.redis;
        autoStart = true;
        environmentFiles = [ cfg.secrets.environmentFile ];
        cmd = [
          "sh"
          "-lc"
          ''exec redis-server --save 20 1 --loglevel warning --requirepass "$REDIS_PASSWORD"''
        ];
        volumes = [ "coolify-redis:/data" ];
        extraOptions = [
          "--network=${cfg.networkName}"
          "--network-alias=coolify-redis"
          "--pull=always"
          ''--health-cmd=redis-cli -a "$REDIS_PASSWORD" ping''
          "--health-interval=5s"
          "--health-retries=10"
          "--health-timeout=2s"
        ];
      };

      coolify-realtime = {
        image = cfg.images.realtime;
        autoStart = true;
        environmentFiles = [ "/run/coolify/soketi.env" ];
        ports = [
          "${toString cfg.soketiPort}:6001"
          "6002:6002"
        ];
        volumes = [ "${cfg.stateDir}/ssh:/var/www/html/storage/app/ssh" ];
        extraOptions = [
          "--network=${cfg.networkName}"
          "--network-alias=coolify-realtime"
          "--add-host=host.docker.internal:host-gateway"
          "--pull=always"
          "--health-cmd=wget -qO- http://127.0.0.1:6001/ready && wget -qO- http://127.0.0.1:6002/ready || exit 1"
          "--health-interval=5s"
          "--health-retries=10"
          "--health-timeout=2s"
        ];
      };

      coolify-proxy = {
        image = cfg.images.proxy;
        autoStart = true;
        environmentFiles = [ cfg.secrets.proxyEnvironmentFile ];
        ports = [
          "80:80"
          "443:443"
          "443:443/udp"
          "8080:8080"
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "${cfg.stateDir}/proxy:/traefik"
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
          "--certificatesresolvers.${cfg.proxy.certResolver}.acme.dnschallenge.provider=${cfg.proxy.dnsProvider}"
          "--certificatesresolvers.${cfg.proxy.certResolver}.acme.dnschallenge.delaybeforecheck=0"
        ]
        ++ lib.optionals (cfg.proxy.dnsResolvers != [ ]) [
          "--certificatesresolvers.${cfg.proxy.certResolver}.acme.dnschallenge.resolvers=${lib.concatStringsSep "," cfg.proxy.dnsResolvers}"
        ]
        ++ [
          "--certificatesresolvers.${cfg.proxy.certResolver}.acme.storage=/traefik/acme.json"
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
          "--label=coolify.managed=true"
          "--label=coolify.proxy=true"
        ]
        ++ domainLabels;
      };
    };
  };
}
