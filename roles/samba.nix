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
      browseable = "no";
      writeable = "yes";
      path = "/mnt/data/data";
    };
    sync = {
      browseable = "no";
      writeable = "yes";
      path = "/mnt/data/sync";
    };
    music = {
      browseable = "yes";
      writeable = "yes";
      path = "/mnt/data/music";
      "guest ok" = "yes";
    };
    backup = {
      browseable = "no";
      writeable = "yes";
      path = "/mnt/data/backup";
    };
    torrent = {
      browseable = "no";
      writeable = "yes";
      path = "/mnt/torrent";
    };
  };
}
