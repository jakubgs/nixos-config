{ lib, config, ... }:

let
  inherit (config) services;

  default = { netdata = 9000; mtr = 9001; smartctl = 9002; };

  hosts = {
    "eve.magi.vpn"     = { openwrt = 9100; };
    "arael.magi.vpn"   = default // { mikrotik = 9436; };
    "bardiel.magi.vpn" = default;
    "caspair.magi.vpn" = default;
    "lilim.magi.vpn"   = default;
    "leliel.magi.vpn"  = default;
    "sachiel.magi.vpn" = default;
    "zeruel.magi.vpn"  = default // { beacon-node = 9100; validator-client = 9101; geth = 16060; };
    "israfel.magi.vpn" = default // { beacon-node = 9100; validator-client = 9101; erigon = 16060; };
    "iruel.magi.vpn"   = default;
  };

  # helper for filtering hosts by available service port
  hostsWithPort = service: lib.filterAttrs (_: v: lib.hasAttr service v) hosts;

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
      "--storage.tsdb.retention.size=40GB"
      "--web.external-url=http://${config.networking.fqdn}/prometheus/"
      "--web.route-prefix=/"
    ];

    globalConfig = {
      scrape_interval = "10s";
      scrape_timeout = "5s";
    };

    scrapeConfigs = [
      (genScrapeJob {name = "netdata";          path = "/api/v1/allmetrics";})
      (genScrapeJob {name = "smartctl";         path = "/metrics";})
      (genScrapeJob {name = "beacon-node";      path = "/metrics"; interval = "6s"; })
      (genScrapeJob {name = "validator-client"; path = "/metrics"; interval = "6s"; })
      (genScrapeJob {name = "geth";             path = "/debug/metrics/prometheus"; })
      (genScrapeJob {name = "erigon";           path = "/debug/metrics/prometheus"; })
      (genScrapeJob {name = "mikrotik";         path = "/metrics";})
      (genScrapeJob {name = "openwrt";          path = "/metrics";})
      (genScrapeJob {name = "mtr";              path = "/metrics";})
    ];

    ruleFiles = [
      ../../files/prometheus/rules/netdata.yml
      ../../files/prometheus/rules/smartctl.yml
      ../../files/prometheus/rules/nimbus.yml
      ../../files/prometheus/rules/geth.yml
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
