{
  config,
  lib,
  ...
}:
{
  options.aspects.services.murmur.enable = lib.mkEnableOption "murmur";

  config = lib.mkIf config.aspects.services.murmur.enable {

    # Ensure murmur can read certs
    users.users.murmur.extraGroups = [ "acme" ];

    aspects.services.acme.reloadServices = [
      "murmur.service"
    ];

    services = {
      murmur = {
        enable = true;
        openFirewall = true;
        port = 64738;
        hostName = "";
        welcometext = ''
          Bienvenue sur <b>Rababou</b> !
          <p style='margin-bottom:12px; margin-top:12px'>Le serveur est disponible sur le port <b>${toString config.services.murmur.port}</b></p>
          <p style='margin-bottom:12px; margin-top:12px'>Client web: <a href='https://rababou.ch/mumble'><span style='color:#0b8eb2'>rababou.ch/mumble</span></a></p>
          <p style='margin-bottom:12px; margin-top:12px'>Voir qui est connecté: <a href='https://rababou.ch/mumble-online/'><span style='color:#0b8eb2'>rababou.ch/mumble-online</span></a></p>
          <p style='margin-bottom:12px; margin-top:12px'>Interface web du bot: <a href='https://bot.rababou.ch'><span style='color:#0b8eb2'>bot.rababou.ch</span></a></p>
        '';
        bandwidth = 5111222;
        users = 100;
        registerName = "Rababou";
        bonjour = false;
        logDays = 31;
        imgMsgLength = 400072;
        allowHtml = true;
        sslCert = "${config.security.acme.certs."rababou.ch".directory}/fullchain.pem";
        sslKey = "${config.security.acme.certs."rababou.ch".directory}/key.pem";
        extraConfig = ''
          channelname=.+
          username=.+

          ice="tcp -h 127.0.0.1 -p 6502"

          [Ice]
          Ice.Warn.UnknownProperties=1
          Ice.MessageSizeMax=65536
        '';
      };
    };
  };
}
