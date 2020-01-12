{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.vars.ports.nextcloud
  ];

  # Proxy
  services.nginx = {
    enable = true;
    virtualHosts = {
      ${config.services.nextcloud.hostName} = {
        listen = [{
          addr = "0.0.0.0";
          port = config.vars.ports.nextcloud;
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
        pkgs.writeText "admin-pass-file" secrets.nextCloudAdminPass
      );
    };
  };
  # DB
  services.nextcloud.config = {
    dbtype = "pgsql";
    dbhost = "/run/postgresql";
    dbname = "nextcloud";
    dbuser = "nextcloud";
    dbpass = secrets.nextCloudDBPass;
  };

  systemd.services.nextcloud-setup = {
    requires = ["postgresql.service"];
    after = [ "postgresql.service" ];
  };
}
