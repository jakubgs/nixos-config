{ pkgs, ... }:

{
  # Install vagrant
  users.users.sochan.packages = with pkgs; [ vagrant ];

  # Required for vagrant
  boot.kernelParams = pkgs.lib.mkForce [ "ipv6.disable=0" ];
  networking.enableIPv6 = pkgs.lib.mkForce true;

  # Minimal configuration for NFS support with Vagrant.
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i virbr+ -p tcp -m tcp --dports 2049 -j ACCEPT
  '';
}
