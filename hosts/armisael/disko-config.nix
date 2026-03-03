let
  lib = import ../../lib/disko;

  inherit (lib.zfs) mkDataSet mediaOpts;
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00BL7_S64KNX0T274218";
        content = {
          type = "gpt";
          partitions = {
            efi   = lib.gpt.mkEFI   1 "1G"   "EFI";
            swap  = lib.gpt.mkSwap  2 "6G"   "SWAP";
            root  = lib.gpt.mkZpool 4 "100%" "ZFS";
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = with lib.zfs; rootFsOptions // encryptedOpts;
        datasets = {
          # Name                Mountpoint     Quota  Snapshot Options
          "root"    = mkDataSet "/"            "10G"  true     {};
          "home"    = mkDataSet "/home"        "10G"  true     {};
          "nix"     = mkDataSet "/nix"         "20G"  false    {};
          "git"     = mkDataSet "/mnt/git"     "10G"  true     {};
          "data"    = mkDataSet "/mnt/data"    "50G"  true     mediaOpts;
          "music"   = mkDataSet "/mnt/music"  "150G"  true     mediaOpts;
          "photos"  = mkDataSet "/mnt/photos" "200G"  true     mediaOpts;
          "reserve" = mkDataSet null            "1G"  false    { canmount = "off"; };
        };
      };
    };
  };
}
