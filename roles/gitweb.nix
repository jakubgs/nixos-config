{ config, pkgs, lib, ... }:

{
  options.gitweb = {
    repos =   lib.mkOption { default = "/git"; };
    subpath = lib.mkOption { default = "/gitweb"; };
  };

  config = let
    inherit (pkgs.lib) pathToMountUnit;
    cfg = config.gitweb;
  in {
    # Hosting
    services.nginx = {
      enable = true;
      gitweb = {
        enable = true;
        location = "${cfg.subpath}";
        virtualHost = "${config.networking.hostName}.${config.networking.domain}";
      };
    };

    # Service
    services.gitweb = {
      projectroot = config.gitweb.repos;
      gitwebTheme = true;
    };

    # Wait for mount and start after.
    systemd.services.gitweb = {
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
