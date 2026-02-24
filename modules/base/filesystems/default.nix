{
  config,
  lib,
  ...
}:
{
  config = {
    zramSwap.enable = true;
    boot = {
      tmp = {
        useTmpfs = true;
        tmpfsSize = "40%";
      };

      loader = {
        systemd-boot.enable = false;

        grub = {
          enable = true;
          efiSupport = true;
          efiInstallAsRemovable = true;
          configurationLimit = 5;
        };

        efi = {
          canTouchEfiVariables = false; # no efi on ik
          efiSysMountPoint = "/boot/efi";
        };

        timeout = 5;
      };

      kernel.sysctl = lib.optionalAttrs (builtins.length config.swapDevices > 0) {
        "vm.swappiness" = 10;
      };
    };
  };
}
