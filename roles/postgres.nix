{ pkgs, ... }:

{
  # Service
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    port = 5432;
    authentication = ''
      host all all 127.0.0.1/32 trust
    '';
    ensureDatabases = [ "jakubgs" ];
    ensureUsers = [
      {
        name = "jakubgs";
        ensurePermissions = {
          "DATABASE jakubgs" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
