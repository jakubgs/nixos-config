{ ... }:

{
  # Uptime tracker
  services.uptimed.enable = true;

  # NTP Server
  services.chrony = {
    enable = true;
    initstepslew.enabled = true;
    extraConfig = ''
      makestep 1.0 3
    '';
  };

  # Metrics Exporter
  services.prometheus.exporters.chrony = {
    enable = true;
    port = 9123;
    enabledCollectors = [
      "tracking"
      "sources"
      "serverstats"
    ];
  };
}
