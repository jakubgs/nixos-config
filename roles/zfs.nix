{ ... }:

{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];

  # Snapshot daily
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    monthly = 3;
    weekly = 3;
    daily = 6;
    hourly = 0;
    frequent = 0;
  };
}
