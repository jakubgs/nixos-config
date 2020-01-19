{ pkgs, ... }:

{
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
    exports = ''
      /mnt/data      10.2.2.0/8(rw,no_subtree_check) 192.168.1.0/8(rw,no_subtree_check)
      /mnt/music     10.2.2.0/8(rw,no_subtree_check) 192.168.1.0/8(rw,no_subtree_check)
      /mnt/torrent   10.2.2.0/8(rw,no_subtree_check) 192.168.1.0/8(rw,no_subtree_check)
    '';
  };
}
