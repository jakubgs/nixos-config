{ config, ... }:

let
  cfg = config.services.prometheus.exporters.systemd;
in {
  services.prometheus.exporters.systemd = {
    enable = true;
    port = 9558;
    listenAddress = "0.0.0.0";
    firewallRules = ''
      iifname "zt*" tcp dport ${cfg.port} accept
    '';
  };
}
