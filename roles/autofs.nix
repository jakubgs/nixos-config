{ pkgs, ... }:

{
  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster =
      let
        melchiorConf = pkgs.writeText "autofs-melchior" ''
          git     -fstype=nfs 192.168.1.12:/mnt/git
          data    -fstype=nfs 192.168.1.12:/mnt/data
          music   -fstype=nfs 192.168.1.12:/mnt/music
          photos  -fstype=nfs 192.168.1.12:/mnt/photos
          backup  -fstype=nfs 192.168.1.12:/mnt/backup
          torrent -fstype=nfs 192.168.1.12:/mnt/torrent
        '';
        lelielConf = pkgs.writeText "autofs-leliel" ''
          git     -fstype=nfs leliel.magi.vpn:/mnt/git
          data    -fstype=nfs leliel.magi.vpn:/mnt/data
          music   -fstype=nfs leliel.magi.vpn:/mnt/music
          photos  -fstype=nfs leliel.magi.vpn:/mnt/photos
          torrent -fstype=nfs leliel.magi.vpn:/mnt/torrent
        '';
      in ''
        /mnt/melchior ${melchiorConf}
        /mnt/leliel ${lelielConf}
      '';
  };
}
