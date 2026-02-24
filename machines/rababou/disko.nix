{ config, ... }:
{
  disko = {
    enableConfig = true;
    devices = {
      disk = {
        primary = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "3M";
                type = "EF02";
                priority = 1;
              };
              ESP = {
                size = "128M";
                label = "EFI";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot/efi";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                label = "${config.networking.hostName}";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
