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
  services.mpd.network.port = config.vars.ports.mpd;
  services.mpd.network.listenAddress = "0.0.0.0";
  services.mpd.musicDirectory = "/mnt/music";
  services.mpd.playlistDirectory = "/mnt/music/_playlists";
  services.mpd.extraConfig = ''
    password   "${secrets.mpdPassword}@read,add,control,admin"
    mixer_type "software"
  '';

  # Web UI
  services.ympd.enable = true;
  services.ympd.mpd.host = "localhost";
  services.ympd.webPort = config.vars.ports.ympd;
}
