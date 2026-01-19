{ config, unstablePkgs, lib, ... }:

{
  services.tabby = {
    enable = true;
    port = 11029;
    host = "0.0.0.0";
    package = unstablePkgs.tabby;
    model = "Qwen2.5-Coder-3B";
    acceleration = "cuda";
    usageCollection = false;
  };

  systemd.services.tabby = {
    # For scraping docs pages.
    path = with unstablePkgs; [ katana ];

    # For indexing local repos.
    serviceConfig = {
      User = lib.mkForce "jakubgs";
      Group = lib.mkForce "jakubgs";
      DynamicUser = lib.mkForce false;
      ReadOnlyPaths = ["/home/jakubgs/work"];
      Environment = [
        "HOME=/var/lib/tabby"
        "RUST_LOG=debug"
      ];
    };
  };

  users.users.jakubgs.packages = with unstablePkgs; [
    tabby-agent
  ];

  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [
    config.services.tabby.port
  ];

  # Landing
  services.landing = {
    proxyServices = [{
      name = "/tabby/";
      title = "Tabby";
      value = {
        return = "302 http://localhost:${toString config.services.tabby.port}/";
      };
    }];
  };
}
