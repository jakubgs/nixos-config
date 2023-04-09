{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # SMART drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # SMART metrics exporter
  services.prometheus.exporters.smartctl = {
    enable = true;
    maxInterval = "20s";
  };

  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [
    config.services.prometheus.exporters.smartctl.port
  ];
}
