{ pkgs, config, lib, secret, ... }:

let
  inherit (config) services;
  inherit (lib) types mkEnableOption mkOption mkIf listToAttrs;

  htpasswd = secret "service/landing/htpasswd";

  cfg = config.services.landing;

  landingPage = pkgs.callPackage ../templates/landing.index.nix {
    inherit config;
    inherit (cfg) proxyServices;
  };
in {
  options = {
    services = {
      landing = {
        enable = mkEnableOption "Enabel a fast and simple webserver for your files.";

        htpasswdFile = mkOption {
          type = types.path;
          default = "";
          description = ''
            Location of file with credentials in htpasswd format.
          '';
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
    services.nginx = {
      enable = true;
      enableReload = true;

      virtualHosts = {
        "${config.networking.fqdn}" = {
          default = false;
          basicAuthFile = cfg.htpasswdFile;
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
