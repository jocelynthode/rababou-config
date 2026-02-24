{
  config,
  lib,
  ...
}:
{
  imports = [
    ./containers
  ];

  options.aspects.development.enable = lib.mkEnableOption "development";

  config = lib.mkIf config.aspects.development.enable {
    aspects = {
      development = {
        containers.enable = lib.mkDefault true;
      };
    };
  };
}
