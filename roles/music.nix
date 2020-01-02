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
  services.mpd.enable = true;
  services.mpd.user = "sochan";
  services.mpd.group = "sochan";
  services.mpd.network.listenAddress = "0.0.0.0";
  services.mpd.musicDirectory = "/mnt/data/music";
  services.mpd.playlistDirectory = "/mnt/data/music/_playlists";
  services.mpd.extraConfig = ''
    password   "${secrets.mpdPassword}@read,add,control,admin"
    mixer_type "software"
  '';

  # Web UI
  services.ympd.enable = true;
  services.ympd.mpd.host = "localhost";
  services.ympd.webPort = 8001;
}
