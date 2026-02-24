{
  config,
  lib,
  pkgs-unstable,
  ...
}:
{
  options.aspects.services.commafeed.enable = lib.mkEnableOption "commafeed";

  config = lib.mkIf config.aspects.services.commafeed.enable {

    services = {
      postgresql = {
        ensureDatabases = [
          "commafeed"
        ];
        ensureUsers = [
          {
            name = "commafeed";
            ensureDBOwnership = true;
          }
        ];
      };

      commafeed = {
        enable = true;
        package = pkgs-unstable.commafeed;
        environment = {
          QUARKUS_HTTP_PORT = "8082";
          QUARKUS_DATASOURCE_JDBC_URL = "jdbc:postgresql:///commafeed?host=/run/postgresql";
          COMMAFEED_FEED_REFRESH_USER_INACTIVITY_PERIOD = "180D";
          COMMAFEED_DATABASE_CLEANUP_ENTRIES_MAX_AGE = "0";
          COMMAFEED_DATABASE_CLEANUP_MAX_FEED_CAPACITY = "0";
        };
        environmentFile = config.sops.secrets.commafeed.path;
      };

      nginx.virtualHosts."commafeed.rababou.ch" = {
        onlySSL = true;
        useACMEHost = "rababou.ch";
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${config.services.commafeed.environment.QUARKUS_HTTP_PORT}/";
          };
        };
      };
    };

    aspects.services.acme.certDomains = [ "commafeed.rababou.ch" ];

    sops.secrets.commafeed = {
      sopsFile = ../../../secrets/${config.networking.hostName}/secrets.yaml;
      restartUnits = [ "commafeed.service" ];
    };
  };
}
