{ ... }:

{
  # rsync folders with USB drive
  services.usb-backup = {
    enable = true;
    timeout = 3600;
    frequency = "daily";
    destination = "/mnt/usb_backup";
    sourcePaths = [
      "/mnt/git"
      "/mnt/data"
      "/mnt/music"
      "/mnt/backup"
    ];
  };
}
