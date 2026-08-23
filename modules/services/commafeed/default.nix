{
  config,
  lib,
  pkgs,
  ...
}:
let
  commafeed-postgresql = pkgs.commafeed.overrideMavenAttrs (oldAttrs: {
    mvnParameters = oldAttrs.mvnParameters + " -Ppostgresql";
    # To find it, replace by lib.fakeHash and run nix build .#nixosConfigurations.rababou.config.services.commafeed.package
    # mvhHash = lib.fakeHash;
    mvnHash = "sha256-muLqn39njSLH8zx+DetU3T612YtpJl7vCppKyaC0yzQ=";
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share
      unzip -d $out/share/ commafeed-server/target/commafeed-${oldAttrs.version}-postgresql-jvm.zip
      makeWrapper ${oldAttrs.mvnJdk}/bin/java $out/bin/commafeed \
        --add-flags "-jar $out/share/commafeed-${oldAttrs.version}-postgresql/quarkus-run.jar"
      runHook postInstall
    '';
  });
in
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
        package = commafeed-postgresql;
        environment = {
          QUARKUS_HTTP_PORT = "8082";
          QUARKUS_DATASOURCE_DB_KIND = "postgresql";
          # See https://github.com/Athou/commafeed/issues/1278#issuecomment-4966021207 for why we cant use unix socket
          # QUARKUS_DATASOURCE_JDBC_URL = "jdbc:postgresql:///commafeed?host=/run/postgresql";
          QUARKUS_DATASOURCE_JDBC_URL = "jdbc:postgresql://localhost:5432/commafeed";
          QUARKUS_DATASOURCE_USERNAME = "commafeed";
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
