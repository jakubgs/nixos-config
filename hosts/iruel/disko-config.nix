{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNE0K828163";
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
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";

        options = {
          canmount = "off";
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
              quota = "10G";
              reservation = "10G";
              "com.sun:auto-snapshot" = "true";
            };
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              quota = "10G";
              reservation = "10G";
              "com.sun:auto-snapshot" = "true";
            };
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              quota = "40G";
              reservation = "40G";
            };
          };
          reserve = {
            type = "zfs_fs";
            options = {
              quota = "10G";
              reservation = "10G";
            };
          };
        };
      };
    };
  };
}
