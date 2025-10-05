{ pkgs, config, secret, ... }:

let
  hostname = config.networking.hostName;
in {
  age.secrets = {
    "service/tailscale/${hostname}" = {
      file = ../secrets/service/tailscale/${hostname}.age;
    };
  };

  # Daemon
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-routes=false" "--accept-dns=false" "--ssh=false" ];
    extraSetFlags = [ "--accept-routes=false" "--accept-dns=false" "--ssh=false" ];
    # WARNING: These keys expire after 90 days.
    authKeyFile = secret "service/tailscale/${hostname}";
  };

  # Client
  users.users.jakubgs.packages = with pkgs; [
    tailscale-systray
  ];
}
