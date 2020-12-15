{ config, ... }:

let
  secrets = import ../secrets.nix;
  fqdn = with config.networking; "${hostName}.${domain}";
in {
  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    webExternalUrl = "http://${fqdn}/alertmanager/";
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

  services.prometheus = {
    alertmanagers = [
      { static_configs = [ { targets = [ "localhost:9093" ]; } ]; }
    ];
  };
}
