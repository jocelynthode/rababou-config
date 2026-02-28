{
  config,
  lib,
  ...
}:
{
  options.aspects.services.acme = {
    certDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    reloadServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@rababou.ch";
        webroot = "/var/lib/acme/acme-challenge"; # port 80 already opened in media/nginx
      };
      certs = {
        "rababou.ch" = {
          extraDomainNames = config.aspects.services.acme.certDomains;
          group = "acme";
          inherit (config.aspects.services.acme) reloadServices;
        };
      };
    };
  };
}
