{ lib, config, ... }:

let
  inherit (config) services;
  fqdn = with config.networking; "${hostName}.${domain}";

  hosts = {
    "arael.magi.vpn" = { netdata = 8000; };
    "caspair.magi.vpn" = { netdata = 8000; };
    "lilim.magi.vpn" = { netdata = 8000; };
    "leliel.magi.vpn" = { netdata = 8000; };
    "sachiel.magi.vpn" = { netdata = 8000; };
    "zeruel.magi.vpn" = { netdata = 8000; nimbus = 9100; };
  };

  # helper for filtering hosts by available service port
  hostsWithPort = service: lib.filterAttrs (n: v: lib.hasAttr service v) hosts;

  # helper for generating scrape targets
  genTargets = service:
    lib.mapAttrsToList
    (host: val: "${host}:${toString (lib.getAttr service val)}")
    (hostsWithPort service);

  # helper for generating scrape configs
  genScrapeJob = name: path: {
    job_name = name;
    metrics_path = path;
    scheme = "http";
    honor_labels = true;
    params = { format = [ "prometheus" ]; };
    static_configs = [{ targets = genTargets name; }];
    relabel_configs = [{
      source_labels = [ "__address__" ];
      target_label = "instance";
      regex = "([a-z.-]+):[0-9]+";
    }];
  };
in {
  services.prometheus = {
    enable = true;
    port = 9090;
    checkConfig = true;
    extraFlags = [
      "--storage.tsdb.retention=30d"
      "--web.external-url=http://${fqdn}/prometheus/"
      "--web.route-prefix=/"
    ];

    globalConfig = {
      scrape_interval = "60s";
      scrape_timeout = "5s";
    };

    scrapeConfigs = [
      (genScrapeJob "netdata" "/api/v1/allmetrics")
      (genScrapeJob "nimbus" "/metrics")
    ];

    ruleFiles = [
      ../files/prometheus/rules/netdata.yml
      ../files/prometheus/rules/nimbus.yml
    ];
  };

  services.landing = {
    proxyServices = [{
      name ="/prometheus/";
      title = "Prometheus";
      value = {
        proxyPass = "http://localhost:${toString services.prometheus.port}/";
      };
    }];
  };
}
