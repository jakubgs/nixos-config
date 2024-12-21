{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_250GB_S4EUNF0M663546L";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "6G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            plainSwap = {
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";

        rootFsOptions = {
          canmount = "off";
          mountpoint = "none";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          atime = "off";
          xattr = "sa";
        };

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              canmount = "noauto";
              quota = "10G";
              reservation = "10G";
              "com.sun:auto-snapshot" = "true";
            };
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              canmount = "noauto";
              quota = "10G";
              reservation = "10G";
              "com.sun:auto-snapshot" = "true";
            };
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              canmount = "noauto";
              quota = "40G";
              reservation = "40G";
            };
          };
          reserve = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "none";
              quota = "10G";
              reservation = "10G";
            };
          };
        };
      };
    };
  };
}
