{ config, secret, ... }:

let
  webhook = secret "service/alertmanager/discord-webhook";
in {
  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    webExternalUrl = "http://${config.networking.fqdn}/alertmanager/";
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
            { api_url = "${webhook}/slack";
              channel = "alerts"; }
          ];
        }
      ];
    };
  };

  services.prometheus = {
    alertmanagers = [
      { static_configs = [ { targets = [ "localhost:9093" ]; } ]; }
    ];
  };

  services.landing = {
    proxyServices = [{
      name = "/alertmanager/";
      title = "AlertManager";
      value = {
        proxyPass =
          "http://localhost:${toString config.services.prometheus.alertmanager.port}/";
      };
    }];
  };
}
