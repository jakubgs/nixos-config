{ ... }:

let
  secrets = import ../secrets.nix;
in {
  # Firewall
  networking.firewall.allowedTCPPorts = [ 9091 ];

  # Daemon
  services.transmission = {
    enable = true;
    port = 9091;
    home = "/mnt/media/torrent";
    user = "sochan";
    group = "sochan";
    settings = {
      download-dir = "/mnt/media/torrent";
      incomplete-dir-enabled = false;
      rename-partial-files = true;
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.1.*,10.2.2.*";
      rpc-host-whitelist = "melchior.magi,melchior.magi.local";
      rpc-authentication-required = true;
      rpc-username = "sochan";
      rpc-password = secrets.rcpPassword;
      # a separate service watches for torrent files to start
      watch-dir-enabled = false;
    };
  };

  # Directory Watcher - Recursively starts torrents
  services.transmission-watch = {
    enable = true;
    watchDir = "/mnt/media/torrent/watched";
    downloadDir = "/mnt/media/torrent/";
  };
}
