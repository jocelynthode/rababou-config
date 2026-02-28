{
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

  config = {
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
