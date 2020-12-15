{ lib, ... }:

let
  secrets = import ../secrets.nix;

  hosts = {
    "arael.magi.vpn" = { netdata = 8000; };
    "caspair.magi.vpn" = { netdata = 8000; };
    "zeruel.magi.vpn" = { netdata = 8000; nimbus = 9100; };
  };

  /* helper for filtering hosts by available service port */
  hostsWithPort = service: lib.filterAttrs (n: v: lib.hasAttr service v) hosts;

  /* helper for generating scrape targets */
  genTargets = service: lib.mapAttrsToList (
    host: val: "${host}:${toString (lib.getAttr service val)}"
  ) (hostsWithPort service);

  /* helper for generating scrape configs */
  genScrapeJob = name: path: {
    job_name = name;
    metrics_path = path;
    scheme = "http";
    honor_labels = true;
    params = { format = [ "prometheus" ]; };
    static_configs = [{ 
      targets = genTargets name;
    }];
    relabel_configs = [
      { source_labels = ["__address__"];
        target_label = "instance";
        regex = "([a-z.-]+):[0-9]+"; }
    ];
  };
in {
  services.prometheus = {
    enable = true;
    port = 9090;
    checkConfig = true;
     extraFlags = [
      "--storage.tsdb.retention=30d"
      "--web.external-url=http://arael.magi.vpn/prometheus/"
      "--web.route-prefix=/"
    ];

    globalConfig = {
      scrape_interval = "30s";
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

    alertmanagers = [
      { static_configs = [ { targets = [ "localhost:9093" ]; } ]; }
    ];
  };

  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    webExternalUrl = "http://arael.magi.vpn/alertmanager/";
    extraFlags = [ "--web.route-prefix=/" ];

    configuration = {
      route = {
        # Default destination fo all alerts not matching any routes.
        receiver = "discord-alerts";
        repeat_interval = "1h";
      };

      receivers = [
        {
          name = "discord-alerts";
          /* Discord accepts Slack API payloads under /slack. */
          slack_configs = [
            { api_url = "${secrets.prometheusDiscordWebHook}/slack";
              channel = "alerts"; }
          ];
        }
      ];
    };
  };
}
