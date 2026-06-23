{ config, pkgs, lib, ... }:

{
  options.gitweb = {
    repos =   lib.mkOption { default = "/git"; };
    subpath = lib.mkOption { default = "/webgit"; };
  };

  config = let
    inherit (pkgs.lib) pathToMountUnit;
    cfg = config.gitweb;
  in {
    # Hosting
    services.nginx.enable = true;

    # Service
    services.cgit.main = {
      enable = true;
      scanPath = cfg.repos;
      nginx = {
        virtualHost = "${config.networking.hostName}.${config.networking.domain}";
        location = "${cfg.subpath}/";
      };
      # HTTP clone allowed for all repos under scanPath.
      gitHttpBackend.checkExportOkFiles = false;

      settings = {
        # Useful defaults. Remove if unwanted.
        enable-index-links = true;
        enable-commit-graph = true;
        enable-log-filecount = true;
        enable-log-linecount = true;

        # Required when cgit is mounted under /gitweb/.
        css = "${cfg.subpath}/cgit.css";
        js = "${cfg.subpath}/cgit.js";
        logo = "${cfg.subpath}/cgit.png";
        favicon = "${cfg.subpath}/favicon.ico";
      };
    };

    # Wait for mount and start after.
    systemd.services."fcgiwrap-cgit-main" = {
      after =    [ (pathToMountUnit cfg.repos) ];
      wantedBy = [ (pathToMountUnit cfg.repos) ];
      unitConfig.ConditionPathIsMountPoint = cfg.repos;
    };

    services.landing = {
      proxyServices = [{
        name = "${cfg.subpath}/";
        title = "WebGit";
        value = {
          proxyPass = "http://localhost:80${cfg.subpath}/";
          extraConfig = ''
            proxy_set_header Host default;
          '';
        };
      }];
    };
  };
}
