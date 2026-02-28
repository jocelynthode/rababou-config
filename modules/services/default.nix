{
  lib,
  ...
}:
{
  imports = [
    ./acme
    ./commafeed
    ./continuwuity
    ./fail2ban
    ./murmur
    ./nginx
    ./postgresql
  ];

  config = {
    aspects = {
      services = {
        commafeed.enable = lib.mkDefault true;
        continuwuity.enable = lib.mkDefault true;
        fail2ban.enable = lib.mkDefault true;
        murmur.enable = lib.mkDefault true;
        nginx.enable = lib.mkDefault true;
        postgresql.enable = lib.mkDefault true;
      };
    };
  };
}
