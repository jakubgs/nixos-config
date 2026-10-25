{ config, lib, ... }:

let
  joinSpace = lib.concatStringsSep " ";
  joinComma = lib.concatStringsSep ",";
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
    # Zerotier
    "10.2.2.11" # caspair
    "10.2.2.12" # lilim
    "10.2.2.13" # balthasar
    "10.2.2.14" # armisael
    "10.2.2.25" # tvstick
    # Local Network
    "192.168.1.101" # caspair
    "192.168.1.103" # lilim
  ];

  options = [
    "rw"               # Allow read and write access
    "insecure"         # Allow unprivileged client ports (≥1024)
    "root_squash"      # Map client root user to anonymous user
    "no_subtree_check" # Disable subtree checks for better reliability
  ];

  # Tempalte NFS config
  fsExports = map (fs: ''
    ${fs} ${joinSpace (map (r: "${r}(${joinComma options})") allowIpRanges)}
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
