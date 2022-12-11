{ ... }:

{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];

  # Enable hibernation
  boot.zfs.allowHibernation = true;
  # Importing a suspended pool can corrupt it
  boot.zfs.forceImportRoot = false;
  boot.zfs.forceImportAll = false;

  # Snapshot daily
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    monthly = 0;
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
