{ ... }:

let
  secrets = import ../secrets.nix;
in {
  services.prometheus.exporters = {
    mikrotik = {
      enable = true;
      openFirewall = true;
      listenAddress = "0.0.0.0";
      port = 9436;
      configuration ={
        devices = [
          {
            name = "adam";
            address = "192.168.1.2";
            user = "prometheus";
            password = secrets.mikrotikPassword;
          }
        ];
        features = {
          dhcp = true;
          routes = true;
        };
      };
    };
  };
}
