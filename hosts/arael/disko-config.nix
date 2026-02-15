let
  lib = import ../../lib/disko;

  inherit (lib.zfs) mkDataSet encryptedOpts;

  # Reduce memory usage on datasets for big files.
  mediaOpts = {
    primarycache = "metadata";
    secondarycache = "metadata";
    recordsize = "1M";
    compression = "lz4";
  };
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S2000G_50026B7381D2D265";
        content = {
          type = "gpt";
          partitions = {
            efi   = lib.gpt.mkEFI   1 "1G"   "EFI";
            swap  = lib.gpt.mkSwap  2 "8G"   "SWAP";
            l2arc = lib.gpt.mkPart  3 "8G"   "L2ARC";
            root  = lib.gpt.mkZpool 4 "100%" "ZFS";
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        inherit (lib.zfs) rootFsOptions;
        datasets = {
          # Name                       Mountpoint     Quota  Snapshot Options
          "root"           = mkDataSet "/"            "10G"  true     {};
          "home"           = mkDataSet "/home"        "10G"  true     {};
          "nix"            = mkDataSet "/nix"         "20G"  false    {};
          "secret/torrent" = mkDataSet "/mnt/torrent" "1.7T" false    (encryptedOpts // mediaOpts);
          "reserve"        = mkDataSet null           "2G"   false    { canmount = "off"; };
        };
      };
    };
  };
}
