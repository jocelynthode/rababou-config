{
  config,
  ...
}:
{

  networking = {
    hosts = {
      "127.0.0.1" = [
        config.networking.hostName
        "localhost"
      ];
    };
    firewall.enable = true;
    nftables.enable = true;
  };

}
