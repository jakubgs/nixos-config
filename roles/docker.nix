{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "devicemapper";
    extraOptions = "--storage-opt dm.basesize=30G";
  };

  # Fixes: 'IPv4 forwarding is disabled. Networking will not work.'
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  environment.systemPackages = with pkgs; [ docker-compose ];
}
