{ pkgs, config, lib, secret, ... }:

let
  inherit (config) services;
  inherit (lib) types mkEnableOption mkOption mkIf listToAttrs;

  cfg = config.services.landing;

  landingPage = pkgs.callPackage ../templates/landing.index.nix {
    inherit config;
    inherit (cfg) proxyServices;
  };
in {
  options = {
    services = {
      landing = {
        enable = mkEnableOption "Enable a fast and simple webserver for your files.";

        debug = mkEnableOption "Enable Nginx debug logs in /ver/log/nginx/error.log.";

        sslCertificate = mkOption {
          type = types.path;
          default = "";
          description = "Server certificate file.";
        };

        sslCertificateKey = mkOption {
          type = types.path;
          default = "";
          description = "Server certificate key file.";
        };

        clientCertificate = mkOption {
          type = types.path;
          default = "";
          description = "Client CA certificate file.";
        };

        revokeList = mkOption {
          type = types.path;
          default = "";
          description = "CA revocation list file.";
        };

        # This list of sets represents service proxies we support.
        # To simplify merging with 'locations' we use the
        # Nginx path as 'name' and rest of config as 'value'.
        proxyServices = mkOption {
          type = types.listOf types.attrs;
          default = [ ];
          description =
            "List of objects defining paths and Nginx proxy configs.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Firewall
    networking.firewall.interfaces."zt*".allowedTCPPorts = [ 80 443 ];

    services.nginx = {
      enable = true;
      enableReload = true;
      logError = if cfg.debug then "/var/log/nginx/error.log debug" else "stderr";

      virtualHosts = {
        "${config.networking.fqdn}" = {
          default = false;
          forceSSL = true;
          inherit (cfg) sslCertificate sslCertificateKey;
          extraConfig = ''
            ssl_client_certificate ${cfg.clientCertificate};
            ssl_crl                ${cfg.revokeList};
            ssl_verify_client      on;
          '';
          locations = {
            "= /" = {
              root = pkgs.writeTextDir "index.html" landingPage;
              tryFiles = "/index.html =404";
            };
          } // listToAttrs cfg.proxyServices;
        };
      };
    };
  };
}
