{ lib, config, secret, ... }:

{
  options.mikrotik = {
    configFile = lib.mkOption {
      default = secret "service/mikrotik/config";
    };
  };

  config = {
    age.secrets."service/mikrotik/config" = {
      file = ../secrets/service/mikrotik/config.age;
      owner = "mikrotik-exporter";
    };

    services.prometheus.exporters = {
      mikrotik = {
        enable = true;
        openFirewall = true;
        listenAddress = "0.0.0.0";
        port = 9436;
        configFile = config.mikrotik.configFile;
      };
    };

    # Necessary to allow access to config file.
    users.groups.mikrotik-exporter = {
      name = "mikrotik-exporter";
    };
    users.users.mikrotik-exporter = {
      name = "mikrotik-exporter";
      group = "mikrotik-exporter";
      isSystemUser = true;
    };
    systemd.services."prometheus-mikrotik-exporter" = {
      serviceConfig.DynamicUser = false;
    };
  };
}
