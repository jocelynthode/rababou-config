{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.aspects.services.continuwuity.enable = lib.mkEnableOption "continuwuity";

  config = lib.mkIf config.aspects.services.continuwuity.enable {

    networking.firewall = {
      allowedTCPPorts = [
        config.services.livekit.settings.rtc.tcp_port
      ];
      allowedUDPPorts = [
        config.services.livekit.settings.turn.udp_port
      ];
      allowedUDPPortRanges = [
        {
          from = config.services.livekit.settings.turn.relay_range_start;
          to = config.services.livekit.settings.turn.relay_range_end;
        }
        {
          from = config.services.livekit.settings.rtc.port_range_start;
          to = config.services.livekit.settings.rtc.port_range_end;
        }
      ];
    };

    # Restrict room creation only to rababou.ch
    systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "rababou.ch";

    services = {
      livekit = {
        enable = true;
        # uses LoadCredentials from systemd
        keyFile = config.sops.secrets.livekit.path;
        settings = {
          port = 7880;
          bind_addresses = [ "" ];
          rtc = {
            tcp_port = 7881;
            port_range_start = 50100;
            port_range_end = 50200;
            use_external_ip = true;
            enable_loopback_candidate = false;
          };
          room = {
            auto_create = false;
          };
          turn = {
            enabled = true;
            udp_port = 3478;
            relay_range_start = 50300;
            relay_range_end = 50400;
            domain = "livekit.rababou.ch";
          };
        };
      };

      lk-jwt-service = {
        enable = true;
        port = 8081;
        keyFile = config.sops.secrets.livekit.path;
        livekitUrl = "wss://livekit.rababou.ch";
      };

      nginx = {
        virtualHosts = {
          "matrix.rababou.ch" = {
            onlySSL = true;
            useACMEHost = "rababou.ch";
            extraConfig = ''
              client_max_body_size 50m;

              access_log /var/log/nginx/continuwuity.access.log;
              error_log /var/log/nginx/continuwuity.error.log;
            '';
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString (lib.head config.services.matrix-continuwuity.settings.global.port)}";
            };
          };
          "chat.rababou.ch" = {
            onlySSL = true;
            useACMEHost = "rababou.ch";
            extraConfig = ''
              client_max_body_size 50m;

              access_log /var/log/nginx/cinny.access.log;
              error_log /var/log/nginx/cinny.error.log;

              # Dont break site reload since it's an SPA
              try_files $uri $uri/ /index.html;
            '';
            root = pkgs.cinny.override {
              cinny-unwrapped = pkgs.cinny-unwrapped.overrideAttrs (_old: rec {
                version = "b050cd01f9ada1f253b0f5f50c6c1eddaf929978";

                src = pkgs.fetchFromGitHub {
                  owner = "cinnyapp";
                  repo = "cinny";
                  rev = version;
                  hash = "sha256-cIalEC13d++3YZoaWVcKzjF1qCyULPVk8ZalC1fSdDM=";
                };

                npmDepsHash = "sha256-I+Hz2TYo3PJTcSjTgDKi0Epx4kjYLJI+ZfVDZ21SukU=";

                # Re-trigger this because overrideAttrs only replaces the final values
                npmDeps = pkgs.fetchNpmDeps {
                  inherit src;
                  hash = npmDepsHash;
                };
              });

              conf = {
                defaultHomeserver = 0;
                homeserverList = [
                  "rababou.ch"
                ];
                allowCustomHomeservers = false;
                featuredCommunities = {
                  openAsDefault = false;
                  spaces = [
                    "#community:rababou.ch"
                  ];
                };
                hashRouter = {
                  enabled = false;
                  basename = "/";
                };
              };
            };
          };

          # Allow the use of @username:rababou.ch instead of :matrix.rababou.ch
          "rababou.ch" = {
            locations = {
              "/.well-known/matrix/" = {
                proxyPass = "http://127.0.0.1:${toString (lib.head config.services.matrix-continuwuity.settings.global.port)}";
              };
            };
          };
          "livekit.rababou.ch" = {
            onlySSL = true;
            useACMEHost = "rababou.ch";
            extraConfig = ''
              access_log /var/log/nginx/livekit.access.log;
              error_log /var/log/nginx/livekit.error.log;
            '';
            locations = {
              "~ ^/(sfu/get|healthz|get_token)" = {
                proxyPass = "http://127.0.0.1:${toString config.services.lk-jwt-service.port}$request_uri";
                extraConfig = ''
                  proxy_buffering off;
                '';
              };
              "/" = {
                proxyPass = "http://127.0.0.1:${toString config.services.livekit.settings.port}$request_uri";
                proxyWebsockets = true;
                extraConfig = ''
                  proxy_buffering off;
                '';
              };
            };
          };
        };
      };

      matrix-continuwuity = {
        enable = true;
        settings.global = {
          server_name = "rababou.ch";
          port = [ 6167 ];
          allow_announcements_check = true;
          max_request_size = 52428800;
          allow_encryption = false;
          allow_federation = true;
          forbidden_remote_server_names = [ ".*" ];
          new_user_displayname_suffix = "";
          allow_registration = false;
          allow_room_creation = false;
          url_preview_domain_contains_allowlist = [ "*" ];
          require_auth_for_profile_requests = true;
          auto_join_rooms = [ "#community:rababou.ch" ];
          forget_forced_upon_leave = true;
          trusted_servers = [ ];
          well_known = {
            client = "https://matrix.rababou.ch";
            server = "matrix.rababou.ch:443";
            support_email = "foobar@example.com";
          };
          matrix_rtc = {
            foci = [
              {
                type = "livekit";
                livekit_service_url = "https://livekit.rababou.ch";
              }
            ];
          };
        };
      };
    };

    aspects.services.acme.certDomains = [
      "matrix.rababou.ch"
      "chat.rababou.ch"
      "livekit.rababou.ch"
    ];

    sops.secrets = {
      livekit = {
        sopsFile = ../../../secrets/${config.networking.hostName}/secrets.yaml;
        restartUnits = [
          "livekit.service"
          "lk-jwt-service.service"
        ];
      };
    };
  };
}
