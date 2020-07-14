{ pkgs, ... }:

{
  # Service
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    port = 5432;
    ensureDatabases = [ "sochan" ];
    ensureUsers = [
      {
        name = "sochan";
        ensurePermissions = {
          "DATABASE sochan" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
