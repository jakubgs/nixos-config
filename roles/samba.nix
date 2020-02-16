{ pkgs, lib, ... }:

let
  makePublicShare = path: {
    name = builtins.baseNameOf path;
    value = {
      inherit path;
      browseable = "yes";
      writeable = "yes";
      "guest ok" = "yes";
      "guest only" = "yes";
      "force user" = "nobody";
    };
  };
  makePrivateShare = path: {
    name = builtins.baseNameOf path;
    value = {
      inherit path;
      browseable = "no";
      writeable = "yes";
    };
  };
  shares = {
    public = [
      "/mnt/ania"
      "/mnt/data/music"
      "/mnt/torrent/movies"
    ];
    private = [
      "/mnt/data/data"
      "/mnt/data/sync"
      "/mnt/data/backup"
      "/mnt/torrent"
    ];
  };
in {
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
    guest account = nobody
    map to guest = Bad User
  '';
  services.samba.shares = with lib; (
    listToAttrs (map makePublicShare shares.public) //
    listToAttrs (map makePrivateShare shares.private)
  );
}
