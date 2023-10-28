{ config, lib, ... }:

let
  join = lib.concatStringsSep " ";
  isMounted = path: lib.hasAttr path config.fileSystems;

  fileSystems = lib.filter isMounted [
    "/mnt/git"
    "/mnt/data"
    "/mnt/music"
    "/mnt/photos"
    "/mnt/torrent"
    "/mnt/backup"
  ];

  allowIpRanges = [
    "10.2.2.0/8"    # Zerotier VPNC
    "192.168.1.0/8" # Local Network
  ];

  # Tempalte NFS config
  fsExports = map (fs: ''
    ${fs} ${join (map (r: "${r}(rw,no_subtree_check)") allowIpRanges)}
  '') fileSystems;
in {
  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [ 111 2049 4000 4001 4002 ];
  networking.firewall.interfaces."zt*".allowedUDPPorts = [ 111 2049 4000 4001 4002 ];

  # Daemon
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    # exported shares
    exports = lib.concatStringsSep "" fsExports;
  };

  # Increase network window size
  boot.kernel.sysctl = {
    "net.core.rmem_default" = 262144;
    "net.core.wmem_default" = 262144;
    "net.core.rmem_max" = 262144;
    "net.core.wmem_max" = 262144;
    "net.core.netdev_max_backlog" = 300000;
  };
}
