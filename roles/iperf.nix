{ config, ... }:

{
  # Service
  services.iperf3 = {
    enable = true;
    openFirewall = true;
    port = 5201;
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.services.iperf3.port
  ];
}
