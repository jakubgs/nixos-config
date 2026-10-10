{ config, secret, ... }:

{
  imports = [
    ../services/meteo-exporter.nix
    ../services/meteo-dashboard.nix
  ];

  # Secrets
  age.secrets."service/meteo/password" = {
    file = ../secrets/service/meteo/password.age;
  };

  services.meteo-exporter = {
    enable = true;
    listenAddress = "0.0.0.0";
    passwordFile = secret "service/meteo/password";
  };

  services.meteo-dashboard = {
    enable = true;
    frequency = "*:0/5"; # Every 5 min
    station = "PWS-E5FE9C";
    outputDirectory = "/var/www/meteo-dashboard";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jakub@gsokolowski.pl";
    # Brassero 1-in-5 station supports RSA but not ECDSA.
    certs."meteo.jgs.pw".keyType = "rsa2048";
  };

  services.nginx = {
    enable = true;
    virtualHosts."meteo.jgs.pw" = {
      addSSL = true;
      enableACME = true;
      # Lower OpenSSL security level for legacy TLS client.
      extraConfig = ''
        ssl_ciphers DEFAULT:@SECLEVEL=1;
      '';
      locations."/${config.services.meteo-dashboard.station}" = {
        root = config.services.meteo-dashboard.outputDirectory;
        tryFiles = "/index.html =404";
      };
      locations."/weatherstation/updateweatherstation.php" = {
        proxyPass = "http://localhost:${toString config.services.meteo-exporter.port}";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
        '';
      };
    };
  };
}
