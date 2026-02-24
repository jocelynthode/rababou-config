{
  config,
  lib,
  ...
}:
{
  imports = [
    ./acme
    ./commafeed
    ./continuwuity
    ./murmur
    ./nginx
    ./postgresql
  ];

  options.aspects.services.enable = lib.mkEnableOption "services";

  config = lib.mkIf config.aspects.services.enable {
    aspects = {
      services = {
        commafeed.enable = lib.mkDefault true;
        continuwuity.enable = lib.mkDefault true;
        murmur.enable = lib.mkDefault true;
        nginx.enable = lib.mkDefault true;
        postgresql.enable = lib.mkDefault true;
      };
    };
  };
}
