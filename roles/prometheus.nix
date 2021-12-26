{ lib, config, ... }:

let
  inherit (config) services;

  hosts = {
    "eve.magi.vpn" = { openwrt = 9100; };
    "bardiel.magi.vpn" = { netdata = 8000; };
    "caspair.magi.vpn" = { netdata = 8000; };
    "lilim.magi.vpn" = { netdata = 8000; };
    "leliel.magi.vpn" = { netdata = 8000; };
    "sachiel.magi.vpn" = { netdata = 8000; mikrotik = 9436; mtr = 8080; };
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
  genScrapeJob = { name, path, interval ? "10s" }: {
    job_name = name;
    metrics_path = path;
    scrape_interval = interval;
    scheme = "http";
    honor_labels = true;
    params = { format = [ "prometheus" ]; };
    static_configs = [{ targets = genTargets name; }];
    relabel_configs = [{
      source_labels = ["__address__"];
      target_label = "hostname";
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
      "--web.external-url=http://${config.networking.fqdn}/prometheus/"
      "--web.route-prefix=/"
    ];

    globalConfig = {
      scrape_interval = "10s";
      scrape_timeout = "5s";
    };

    scrapeConfigs = [
      (genScrapeJob {name = "netdata";  path = "/api/v1/allmetrics";})
      (genScrapeJob {name = "nimbus";   path = "/metrics";})
      (genScrapeJob {name = "mikrotik"; path = "/metrics";})
      (genScrapeJob {name = "openwrt";  path = "/metrics";})
      (genScrapeJob {name = "mtr";      path = "/metrics";})
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
