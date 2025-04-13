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
      icybox1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10JPCX-24UE4T0_WD-WXL1E8419FT9";
        content = {
          type = "zfs";
          pool = "USB-DATA";
        };
      };
      icybox2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10JPVX-60JC3T0_WD-WX21A566JTDP";
        content = {
          type = "zfs";
          pool = "USB-DATA";
        };
      };
    };
    zpool = let
      mkZfsDataSet = mountpoint: quota: snapshot: options: {
        type = "zfs_fs";
        inherit mountpoint;
        options = {
          inherit quota;
          "reservation" = quota;
          "canmount" = "noauto";
          "com.sun:auto-snapshot" = toString snapshot;
        } // options;
      };

      rootFsOptions = {
        canmount = "off";
        mountpoint = "none";
        compression = "zstd";
        dnodesize = "auto";
        normalization = "formD";
        atime = "off";
        xattr = "sa";
      };

      reserve = mkZfsDataSet null "10G" false { canmount = "off"; };
    in {
      rpool = {
        type = "zpool";
        inherit rootFsOptions;

        datasets = {
          root = mkZfsDataSet "/"     "10G" true  {};
          home = mkZfsDataSet "/home" "10G" true  {};
          nix  = mkZfsDataSet "/nix"  "40G" false {};
          inherit reserve;
        };
      };
      USB-DATA = {
        type = "zpool";
        inherit rootFsOptions;

        datasets = {
          data   = mkZfsDataSet "/mnt/data"   "200G" true {};
          git    = mkZfsDataSet "/mnt/git"    "10G"  true {};
          mobile = mkZfsDataSet "/mnt/mobile" "30G"  true {};
          music  = mkZfsDataSet "/mnt/music"  "150G" true {};
          photos = mkZfsDataSet "/mnt/photos" "100G" true {};
          inherit reserve;
        };
      };
    };
  };
}
