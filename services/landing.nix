{ pkgs, config, lib, ... }:

let
  inherit (config) services;
  inherit (lib) types mkEnableOption mkOption mkIf listToAttrs catAttrs;

  secrets = import ../secrets.nix;

  cfg = config.services.landing;

  landingPage = pkgs.callPackage ../templates/landing.index.nix {
    inherit config;
    inherit (cfg) proxyServices;
  };
  centralPage = pkgs.callPackage ../templates/central.index.nix {
    machines = map (v: "${v}.magi.vpn") cfg.machines;
  };
in {
  options = {
    services = {
      landing = {
        enable =
          mkEnableOption "Enabel a fast and simple webserver for your files.";

        dataDir = mkOption {
          type = types.str;
          default = "info";
          description = "Directory to share with landing.";
        };

        readOnly = mkOption {
          type = types.bool;
          default = true;
          description = "Read only mode (no upload, rename, move, etc...).";
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

        machines = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "List of names of hosts to include in central.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = true;

      virtualHosts = {
        "${config.networking.hostName}.${config.networking.domain}" = {
          basicAuthFile = pkgs.writeText "htpasswd" secrets.landingHtPasswd;

          locations = {
            "= /" = {
              root = pkgs.writeTextDir "index.html" landingPage;
              tryFiles = "/index.html =404";
            };
            "= /central/" = {
              root = pkgs.writeTextDir "central.html" centralPage;
              tryFiles = "/central.html =404";
            };
          } // listToAttrs cfg.proxyServices
            # Pages combining multiple dashboards
            // listToAttrs (map (name: {
              name = "= /central${name}";
              value = {
                root = pkgs.writeTextDir "central.html"
                  (pkgs.callPackage ../templates/central.index.nix {
                    subpath = name;
                    inherit (cfg) machines;
                  });
                tryFiles = "/central.html =404";
              };
            }) (catAttrs "name" cfg.proxyServices));
        };
      };
    };
  };
}
