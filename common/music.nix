{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Clients
  environment.systemPackages = with pkgs; [ mpc_cli ncmpcpp ];

  # Enable sound.
  sound.enable = true;
  sound.extraConfig = "defaults.pcm.card 2";
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.systemWide = true;
  
  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
    config.services.ympd.webPort
  ];

  # Daemon
  services.mpd.enable = true;
  services.mpd.network.listenAddress = "0.0.0.0";
  services.mpd.musicDirectory = "/mnt/data/music";
  services.mpd.playlistDirectory = "/mnt/data/music/_playlists";
  services.mpd.extraConfig = ''
    password  "${secrets.mpdPassword}@read,add,control,admin"
  '';

  # Web UI
  services.ympd.enable = true;
  services.ympd.mpd.host = "localhost";
  services.ympd.webPort = 8001;
}
