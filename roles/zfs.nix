{ ... }:

{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];

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
