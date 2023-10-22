{ config, ... }:

let
  repository = "sftp:u288137@u288137.your-storagebox.de:/home/${config.networking.hostName}";
  makeBackup = name: paths: {
    inherit repository;
    user = "jakubgs";
    initialize = true;
    paths = paths;
    extraBackupArgs = ["--tag=${name}"];
    passwordFile = "/home/jakubgs/.usb_backup_pass";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 3"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
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
