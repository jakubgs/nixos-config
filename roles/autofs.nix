{ pkgs, ... }:

{
  services.autofs = {
    enable = true;
    autoMaster =
      let
        melchiorConf = pkgs.writeText "melchior" ''
          git     -fstype=nfs 192.168.1.12:/mnt/git
          data    -fstype=nfs 192.168.1.12:/mnt/data
          music   -fstype=nfs 192.168.1.12:/mnt/music
          photos  -fstype=nfs 192.168.1.12:/mnt/photos
          backup  -fstype=nfs 192.168.1.12:/mnt/backup
          torrent -fstype=nfs 192.168.1.12:/mnt/torrent
        '';
      in ''
        /mnt/melchior ${melchiorConf}
      '';
  };
}
