{ config, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.vars.ports.transmission
  ];

  # Daemon
  services.transmission = {
    enable = true;
    port = config.vars.ports.transmission;
    home = "/mnt/torrent";
    user = "sochan";
    group = "sochan";
    settings = {
      download-dir = "/mnt/torrent";
      incomplete-dir-enabled = false;
      rename-partial-files = true;
      # RPC
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.1.*,10.2.2.*";
      rpc-host-whitelist = "melchior.magi,melchior.magi.local";
      rpc-authentication-required = true;
      rpc-username = "sochan";
      rpc-password = secrets.rpcPassword;
      # separate service watches for torrent files to start
      watch-dir-enabled = false;
      # limits
      download-queue-size = 30;
    };
  };

  # Directory Watcher - Recursively starts torrents
  services.transmission-watch = {
    enable = true;
    watchDir = "/mnt/torrent/watched";
    downloadDir = "/mnt/torrent/";
    rpcUser = "sochan";
    rpcPass = secrets.rpcPassword;
  };
}
