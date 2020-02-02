{ ... }:

{
  # rsync folders with USB drive
  services.usb-backup = {
    enable = true;
    timeout = 3600;
    destination = "/mnt/usb_backup";
    sourcePaths = [
      "/mnt/git"
      "/mnt/data"
      "/mnt/music"
      "/mnt/backup"
      "/mnt/company"
    ];
  };
}
