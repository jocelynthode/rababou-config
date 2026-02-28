{
  config,
  lib,
  ...
}:
{
  options.aspects.services.fail2ban.enable = lib.mkEnableOption "fail2ban";

  config = lib.mkIf config.aspects.services.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      bantime = "1h";
      maxretry = 3;
    };
  };
}
