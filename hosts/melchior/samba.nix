{ config, lib, pkgs, ... }:

{
  # Firewall
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  # Daemon
  services.samba.enable = true;
  services.samba.syncPasswordsByPam = true;
  services.samba.extraConfig = ''
    load printers = no
    printcap name = /dev/null
    printing = bsd
  '';
  services.samba.shares = {
    data = {
      browseable = "no";
      path = "/mnt/data/data";
    };
    sync = {
      browseable = "no";
      path = "/mnt/data/sync";
    };
    music = {
      browseable = "yes";
      path = "/mnt/data/music";
      "guest ok" = "yes";
    };
    backup = {
      browseable = "no";
      path = "/mnt/data/backup";
    };
    torrent = {
      browseable = "no";
      path = "/mnt/media/torrent";
    };
  };
}
