{ pkgs, ... }:

{
  # Tools
  environment.systemPackages = with pkgs; [ samba ];

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
      path = "/mnt/data/data";
      browseable = "no";
      writeable = "yes";
    };
    sync = {
      path = "/mnt/data/sync";
      browseable = "no";
      writeable = "yes";
    };
    backup = {
      path = "/mnt/data/backup";
      browseable = "no";
      writeable = "yes";
    };
    torrent = {
      path = "/mnt/torrent";
      browseable = "no";
      writeable = "yes";
    };
    music = {
      path = "/mnt/data/music";
      browseable = "yes";
      writeable = "yes";
      "guest ok" = "yes";
    };
    ania = {
      path = "/mnt/ania";
      browseable = "yes";
      writeable = "yes";
      "guest ok" = "yes";
      "guest only" = "yes";
    };
    movies = {
      path = "/mnt/torrent/movies";
      browseable = "yes";
      writeable = "yes";
      "guest ok" = "yes";
      "guest only" = "yes";
    };
  };
}
