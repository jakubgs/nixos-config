{ config, ... }:

{
  # Firewall
  networking.firewall.allowedTCPPorts = [ 9091 ];

  # Daemon
  services.transmission = {
    enable = true;
    port = 9091;
    home = "/mnt/media/transmission";
    group = "sochan";
    settings = {
      incomplete-dir-enabled = false;
      rename-partial-files = true;
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.1.*,10.2.2.*";
      rpc-host-whitelist = "melchior.magi,melchior.magi.local";
      watch-dir = "/mnt/media/transmission/watched";
      watch-dir-enabled = true;
    };
  };
}
