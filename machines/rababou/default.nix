{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  aspects = {
    stateVersion = "25.11";
    allowReboot = true;
    development.containers.enable = true;
    services.enable = true;
  };
}
