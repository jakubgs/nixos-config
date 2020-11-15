{ config, lib, ... }:

let
  join = lib.concatStringsSep " ";
  fileSystems = [
    "/mnt/git"
    "/mnt/data"
    "/mnt/music"
    "/mnt/photos"
    "/mnt/torrent"
  ] ++ lib.optionals (config.networking.hostName == "melchior") [
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
  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 ];

  # Daemon
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    # exported shares
    exports = lib.concatStringsSep "" fsExports;
  };
}
