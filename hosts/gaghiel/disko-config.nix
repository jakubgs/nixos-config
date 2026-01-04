{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/mmc-DA6064_0x16f81d00";
        content = {
          type = "gpt";
          partitions = {
            uboot = {
              priority = 1;
              start = "1M";
              size  = "8M";
              type  = "8300";
              content = null;
            };
            EFI = {
              priority = 2;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            plainSwap = {
              priority = 3;
              size = "4G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
            root = {
              priority = 4;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
