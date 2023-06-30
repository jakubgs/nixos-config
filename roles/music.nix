{ pkgs, lib, config, secret, ... }:

let
  password = secret "service/mpd/pass";
in {
  # Clients
  environment.systemPackages = with pkgs; [ mpc_cli ncmpcpp ];

  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
    config.services.ympd.webPort
  ];

  # Necessary to use PulseAudio
  hardware.pulseaudio.systemWide = true; 
  hardware.pulseaudio.extraConfig = ''
    load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
  '';

  # Daemon
  services.mpd = {
    enable = true;
    user = "mpd";
    group = "jakubgs";
    network.port = 6600;
    network.listenAddress = "0.0.0.0";
    musicDirectory = "/mnt/music";
    playlistDirectory = "/mnt/music/_playlists";
    extraConfig = ''
      password   "${password}@read,add,control,admin"
      mixer_type "software"
      audio_buffer_size "8192"
    ${lib.optionalString config.hardware.pulseaudio.enable ''
      audio_output {
        type "pulse"
        name "Pulseaudio"
        server "127.0.0.1"
      }
    ''}'';
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
