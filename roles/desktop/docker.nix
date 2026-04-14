{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    # Avoid DNS issues caused by DNSMasq setup.
    daemon.settings = {
      dns = [ "1.1.1.1" "8.8.8.8" ];
    };
  };

  # Fixes: 'IPv4 forwarding is disabled. Networking will not work.'
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  environment.systemPackages = with pkgs; [ docker-compose ];
}
