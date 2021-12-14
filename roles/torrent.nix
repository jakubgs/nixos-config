{ config, ... }:

let
  secrets = import ../secrets.nix;
  listenPort = 9091;
  torrentDir = "/mnt/torrent";
  torrentUser = "jakubgs";
in {
  imports = [
    ../services/transmission-watch.nix
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ listenPort ];

  # Daemon
  services.transmission = {
    enable = true;
    home = torrentDir;
    user = torrentUser;
    group = torrentUser;
    settings = {
      download-dir = torrentDir;
      incomplete-dir-enabled = false;
      rename-partial-files = true;
      # RPC
      rpc-port = listenPort;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.1.*,10.2.2.*";
      rpc-host-whitelist = "melchior.magi.vpn,melchior.magi.local";
      rpc-authentication-required = true;
      rpc-username = torrentUser;
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
    watchDir = "${torrentDir}/watched";
    downloadDir = torrentDir;
    rpcUser = torrentUser;
    rpcPass = secrets.rpcPassword;
  };

  services.landing = {
    proxyServices = [
      {
        name ="/torrent/";
        title = "Transmission";
        value = {
          proxyPass = "http://localhost:${toString config.services.transmission.port}/";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_pass_header Authorization;
          '';
        };
      }
    ];
  };
}
