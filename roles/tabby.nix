{ config, pkgs, lib, ... }:

{
  services.tabby = {
    enable = true;
    port = 11029;
    host = "0.0.0.0";
    package = pkgs.unstable.tabby;
    model = "Qwen2.5-Coder-3B";
    acceleration = "cuda";
    usageCollection = false;
  };

  systemd.services.tabby = {
    # For scraping docs pages.
    path = with pkgs; [ pkgs.unstable.katana ];

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

  users.users.jakubgs.packages = with pkgs; [
    pkgs.unstable.tabby-agent
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
