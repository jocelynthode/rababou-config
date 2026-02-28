{
  config,
  lib,
  ...
}:
{
  options.aspects.services.nginx.enable = lib.mkEnableOption "nginx";

  config = lib.mkIf config.aspects.services.nginx.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # Ensure nginx can read certs
    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      appendConfig = ''
        error_log syslog:server=unix:/dev/log,tag=nginx warn;
      '';
      appendHttpConfig = ''
        access_log syslog:server=unix:/dev/log,tag=nginx combined;
      '';
      virtualHosts."rababou.ch" = {
        forceSSL = true;
        useACMEHost = "rababou.ch";
      };
    };
  };
}
