{ config, secret, ... }:

{
  age.secrets."service/alertmanager/webhook" = {
    file = ../secrets/service/alertmanager/webhook.age;
  };

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
          discord_config = [
            { webhook_url_file = "${secret "service/alertmanager/webhook"}/slack"; }
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
      title = "Alertmanager";
      value = {
        proxyPass =
          "http://localhost:${toString config.services.prometheus.alertmanager.port}/";
      };
    }];
  };
}
