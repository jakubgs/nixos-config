{ pkgs, lib, config, secret, ... }:

{
  options.music = {
    collection = lib.mkOption { default = "/mnt/music"; };
    password = lib.mkOption   { default = secret "service/mpd/pass"; };
  };

  config = let
    cfg = config.music;
  in {
    # Clients
    environment.systemPackages = with pkgs; [ mpc_cli ncmpcpp ];

    # Firewall
    networking.firewall.allowedTCPPorts = [
      config.services.mpd.network.port
      config.services.ympd.webPort
    ];

    # Necessary to use PulseAudio
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
      musicDirectory = cfg.collection;
      playlistDirectory = "${cfg.collection}/_playlists";
      extraConfig = ''
        password   "${cfg.password}@read,add,control,admin"
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

    systemd.services.mpd = {
      after = [
        "network.target" "sound.target"
        (pkgs.lib.pathToMountUnit cfg.collection)
      ];
      unitConfig.ConditionPathIsMountPoint = cfg.collection;
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
  };
}
