{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Clients
  environment.systemPackages = with pkgs; [ mpc_cli ncmpcpp ];

  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
    config.services.ympd.webPort
  ];

  # Daemon
  services.mpd = {
    enable = true;
    user = "sochan";
    group = "sochan";
    network.port = 6600;
    network.listenAddress = "0.0.0.0";
    musicDirectory = "/mnt/music";
    playlistDirectory = "/mnt/music/_playlists";
    extraConfig = ''
      password   "${secrets.mpdPassword}@read,add,control,admin"
      mixer_type "software"
    '';
  };

  # Web UI
  services.ympd = {
    enable = true;
    mpd.host = "localhost";
    webPort = 8001;
  };

  services.landing = {
    proxyServices = [{
      name = "/mpd/";
      title = "YMPD";
      value = {
        proxyPass = "http://localhost:${toString config.services.ympd.webPort}/";
      };
    }];
  };
}
