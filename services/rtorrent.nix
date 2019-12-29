{ config, lib, pkgs, ... }:

with lib;

let
  cfg   = config.services.rtorrent;
  bash  = "/run/current-system/sw/bin/bash";
  chmod = "/run/current-system/sw/bin/chmod";
in {
  options = {
    services = {
      rtorrent = {
        enable = mkEnableOption "rTorrent daemon";

        workDir = mkOption {
          type = types.str;
          default = "/var/run/rtorrent";
          description = ''
            Directory for rtorrent working files.
          '';
        };

        dataDir = mkOption {
          type = types.str;
          default = "/home/${cfg.user}/rtorrent";
          description = ''
            Directory for rtorrent data.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "rtorrent";
          description = ''
            User account under which rTorrent runs.
          '';
        };

        group = mkOption {
          type = types.str;
          default = "rtorrent";
          description = ''
            Group under which rTorrent runs.
          '';
        };

        extraConfig = mkOption {
          type = types.str;
          default = "";
          description = ''
            Runtime configuration for rTorrent.
          '';
        };

        portRange = mkOption {
          type = types.str;
          default = "6890-6999";
          description = ''
            Port range to use for listening.
          '';
        };
        
        dhtPort = mkOption {
          type = types.str;
          default = "6881";
          description = ''
            Listening port for DHT (distributed hash table).
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rtorrent =
      let 
        rpcSocket = "${cfg.workDir}/rtorrent.sock";
        dtachSock = "${cfg.workDir}/rtorrent.dtach";
        pidFile   = "${cfg.workDir}/rtorrent.pid";
        logFile   = "${cfg.workDir}/rtorrent.log";

        dtach     = "${pkgs.dtach}/bin/dtach";
        killall   = "${pkgs.killall}/bin/killall";
        rtorrent  = "${pkgs.rtorrent}/bin/rtorrent";

        rcFile = "${cfg.workDir}/rtorrent.rc";
        rcContents = ''
          check_hash              = yes
          encoding_list           = UTF-8
          protocol.encryption.set = allow_incoming,try_outgoing,enable_retry
          trackers.use_udp.set    = no
          protocol.pex.set        = yes
          dht.mode.set            = on
          dht.port.set            = ${cfg.dhtPort}
          directory.default.set   = ${cfg.dataDir}
          session.path.set        = ${cfg.workDir}/session
          network.scgi.open_local = ${rpcSocket}
          network.port_range.set  = ${cfg.portRange}
          network.port_random.set = no
          log.execute = (cat, ${logFile})
          schedule2 = dht_add_node, 0, 0, "dht.add_node=router.bittorrent.com"
          schedule2 = scgi_set_permission, 0, 0, "execute.nothrow = ${chmod}, \"g+w,o=\", ${rpcSocket}"
          execute.nothrow = ${bash}, -c, (cat, "echo -n > ${pidFile} ", (system.pid))
          schedule = watch_directory_1,5,5,"load.start=${cfg.dataDir}/watched/*.torrent"
        '' + cfg.extraConfig;
      in {
        enable = true;
        preStart = ''
          mkdir -m 0700 -p ${cfg.workDir}
          chown ${cfg.user} ${cfg.workDir}
          echo '${rcContents}' > "${rcFile}"
          rm -f ${dtachSock}
        '';
        serviceConfig = {
          User = cfg.user;
          Group = cfg.user;
          KillMode = "none";
          ExecStop = "${killall} -w -s INT ${rtorrent}";
          ExecStart = "${dtach} -N ${dtachSock} -E -z ${rtorrent} -n -o import=${rcFile}";
          Restart = "on-failure";
        };
        environment = {
          TERM = "xterm";
        };
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "local-fs.target" ];
      };

    environment.systemPackages = [ pkgs.rtorrent ];

    users.users = mkIf (cfg.user == "rtorrent") {
      rtorrent = {
        group = cfg.group;
        home = cfg.workDir;
        description = "rTorrent Daemon user";
      };
    };

    users.groups = mkIf (cfg.group == "rtorrent") {
      rtorrent = {};
    };
  };
}
