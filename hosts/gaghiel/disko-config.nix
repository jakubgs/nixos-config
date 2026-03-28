let
  lib = import ../../lib/disko;

  inherit (lib.zfs) mkDataSet encryptedOpts mediaOpts;
in {
  disko.devices = {
    disk = {
      emmc = {
        type = "disk";
        device = "/dev/disk/by-id/mmc-DA6064_0x16f81d00";
        content = {
          type = "gpt";
          partitions = {
            uboot = {
              priority = 1;
              start = "16M"; /* Leave space for EKD2 UEFI */
              size  = "8M";
              type  = "8300";
              content = null;
            };
            efi   = lib.gpt.mkEFI  2 "1G"   "EFI";
            swap  = lib.gpt.mkSwap 3 "4G"   "SWAP";
            l2arc = lib.gpt.mkPart 4 "16G"  "L2ARC";
            root  = lib.gpt.mkExt4 5 "100%" "ROOT"  "/";
          };
        };
      };
      icybox1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10SPZX-22Z10T1_WD-WXE1A69R9SRE";
        content = {
          type = "zfs";
          pool = "USB-DATA";
        };
      };
      icybox2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10SPZX-22Z10T1_WD-WXQ1A49E7EK1";
        content = {
          type = "zfs";
          pool = "USB-DATA";
        };
      };
    };
    zpool = {
      USB-DATA = {
        type = "zpool";
        rootFsOptions = with lib.zfs; rootFsOptions // encryptedOpts;
        datasets = {
          # Name                Mountpoint      Quota Snapshot Options
          "git"     = mkDataSet "/mnt/git"      "10G" true     {};
          "data"    = mkDataSet "/mnt/data"     "50G" true     mediaOpts;
          "mobile"  = mkDataSet "/mnt/mobile"   "30G" true     mediaOpts;
          "music"   = mkDataSet "/mnt/music"   "150G" true     mediaOpts;
          "photos"  = mkDataSet "/mnt/photos"  "200G" true     mediaOpts;
          "reserve" = mkDataSet null             "1G" false    { canmount = "off"; };
        };
      };
    };
  };
}
