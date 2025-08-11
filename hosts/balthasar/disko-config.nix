{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KXG6AZNV256G_TOSHIBA_303F7889F6B1";
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
                randomEncryption = true;
                priority = 100; # prefer to encrypt as long as we have space for it
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
    zpool = let
      mkZfsDataSet = mountpoint: quota: snapshot: options: {
        type = "zfs_fs";
        inherit mountpoint;
        options = {
          inherit quota;
          "reservation" = quota;
          "canmount" = "noauto";
          "com.sun:auto-snapshot" = if snapshot then "true" else "false";
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
        # Encryption
        encryption = "aes-256-gcm";
        keyformat = "passphrase";
      };
    in {
      rpool = {
        type = "zpool";
        inherit rootFsOptions;

        datasets = {
          root    = mkZfsDataSet "/"           "10G"   true {};
          home    = mkZfsDataSet "/home"       "10G"   true {};
          nix     = mkZfsDataSet "/nix"        "40G"  false {};
          data    = mkZfsDataSet "/mnt/data"   "50G"   true {};
          git     = mkZfsDataSet "/mnt/git"    "10G"   true {};
          photos  = mkZfsDataSet "/mnt/photos" "100G"  true {};
          reserve = mkZfsDataSet null          "10G"  false { canmount = "off"; };
        };
      };
    };
  };
}
