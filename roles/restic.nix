{ ... }:

let
  makeBackup = name: paths: {
    user = "jakubgs";
    initialize = true;
    timerConfig = { OnCalendar = "daily"; Persistent = true; };
    repository = "sftp:u288137@u288137.your-storagebox.de:/home/${name}";
    paths = paths;
    passwordFile = "/home/jakubgs/.usb_backup_pass";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 3"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
  };
in {
  services.restic = {
    backups = {
      "company"   = makeBackup "company"   ["/mnt/data/company"];
      "documents" = makeBackup "documents" ["/mnt/data/documents"];
      "important" = makeBackup "important" ["/mnt/data/important"];
    };
  };
}
