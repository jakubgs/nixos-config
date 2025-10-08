{ pkgs, ... }:

{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];

  # Pin version
  boot.zfs.package = pkgs.zfs_2_3;
  # Enable hibernation
  boot.zfs.allowHibernation = true;
  # Importing a suspended pool can corrupt it
  boot.zfs.forceImportRoot = false;
  boot.zfs.forceImportAll = false;
  # Fix missing symbols dropped in kernel 6.2.
  boot.zfs.removeLinuxDRM = true;

  # Snapshot daily
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    monthly = 2;
    weekly = 2;
    daily = 6;
    hourly = 0;
    frequent = 0;
  };

  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
}
