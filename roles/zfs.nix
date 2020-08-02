{ ... }:

{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];

  # Snapshot daily
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    monthly = 4;
    weekly = 4;
    daily = 7;
    hourly = 0;
    frequent = 0;
  };
}
