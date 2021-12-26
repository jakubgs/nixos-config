{ pkgs, config, secret, ... }:

let
  dbPass = secret "service/nextcloud/db/pass";
  adminPass = secret "service/nextcloud/admin/pass";

  listenPort = 8002;
in {
  # Firewall
  networking.firewall.allowedTCPPorts = [ listenPort ];

  # Proxy
  services.nginx = {
    enable = true;
    virtualHosts = {
      ${config.services.nextcloud.hostName} = {
        listen = [{
          addr = "0.0.0.0";
          port = listenPort;
        }];
      };
    };
  };

  # Database
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      { name = "nextcloud";
        ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; }; }
    ];
  };

  # Daemon
  services.nextcloud = {
    enable = true;
    home = "/mnt/nextcloud";
    hostName = "melchior.magi.local";
    nginx.enable = true;
    config = {
      extraTrustedDomains = [ "melchior.magi" ];
      adminuser = "admin";
      adminpassFile = toString (
        pkgs.writeText "admin-pass-file" adminPass
      );
    };
  };

  # DB
  services.nextcloud.config = {
    dbtype = "pgsql";
    dbhost = "/run/postgresql";
    dbname = "nextcloud";
    dbuser = "nextcloud";
    dbpass = dbPass;
  };

  systemd.services.nextcloud-setup = {
    requires = ["postgresql.service"];
    after = [ "postgresql.service" ];
  };
}
