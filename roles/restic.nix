{ ... }:

{
  services.restic = {
    backups = {
      "company" = {
        user = "jakubgs";
        initialize = true;
        timerConfig = { OnCalendar = "daily"; Persistent = true; };
        repository = "sftp:u288137@u288137.your-storagebox.de:/home/company";
        paths = ["/mnt/data/company"];
        passwordFile = "/home/jakubgs/.usb_backup_pass";
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 3"
          "--keep-monthly 12"
          "--keep-yearly 3"
        ];
      };
    };
  };
}
