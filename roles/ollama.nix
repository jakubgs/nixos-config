{ lib, config, ... }:

{
  options.ollama = {
    domain    = lib.mkOption { default = "${config.networking.hostName}.magi.vpn"; };
    apiPort   = lib.mkOption { default = 11434; };
    webuiPort = lib.mkOption { default = 3000;  };
  };

  config = let
    cfg = config.ollama;
  in {
    users.users.ollama.uid = 3000;
    users.groups.ollama.gid = 3000;

    services.ollama = {
      enable = true;
      port = cfg.apiPort;
      user = "ollama";
      group = "ollama";
      home = "/var/lib/ollama";
      acceleration = "cuda";
      loadModels = [
        "llama2-uncensored:7b"
        "dolphin-llama3:8b"
      ];
    };

    services.open-webui = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.webuiPort;
      environment = {
        OLLAMA_API_BASE_URL = "http://localhost:${toString cfg.apiPort}";
        WEBUI_HOSTNAME = config.networking.fqdn;
        WEBUI_AUTH = "False";
      };
    };

    services.landing = {
      proxyServices = [{
        name = "/open-webui/";
        title = "Open WebUI";
        value = {
          return = "302 http://${cfg.domain}:${toString cfg.webuiPort}/";
        };
      }];
    };

    networking.firewall.interfaces."zt*".allowedTCPPorts = [ cfg.webuiPort ];
  };
}
