{ pkgs, config, secret, ... }:

{
  age.secrets."service/tailscale/lilim" = {
    file = ../secrets/service/tailscale/lilim.age;
  };
  age.secrets."service/tailscale/caspair" = {
    file = ../secrets/service/tailscale/caspair.age;
  };

  # Daemon
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secret "service/tailscale/${config.networking.hostName}";
  };

  # Client
  users.users.jakubgs.packages = with pkgs; [
    tailscale-systray
  ];
}
