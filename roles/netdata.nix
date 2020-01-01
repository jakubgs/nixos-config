{ config, ... }:

{
  # Firewall
  networking.firewall.allowedTCPPorts = [ config.services.netdata.port ];

  # Daemon
  services.netdata.enable = true;
  services.netdata.port = 9002;
  services.netdata.config = {
    "global" = {
        "hostname" = config.networking.hostName;
        "run as user" = "root";
        "update every" = 5;
        "memory mode" = "ram";
        "error log" = "/var/log/netdata/error.log";
        "debug log" = "none";
        "access log" = "none";
    };
    "web" = {
       "default port" = config.services.netdata.port;
       "allow connections from" = "localhost 10.2.2.* 192.168.1.*";
    };
    "health" = {
        "enabled" = "no";
    };
    "statsd" = {
        "enabled" = "no";
    };
    "plugins" = {
        "idlejitter" = "no";
        "python.d" = "no";
        "node.d" = "no";
        "charts.d" = "no";
        "fping" = "no";
        "tc" = "no";
    };
    "plugin:apps" = {
        "update every" = 10;
    };
    "plugin:proc:diskspace" = {
        "update every" = 10;
        "check for new mount points every" = 0;
    };
    "plugin:proc" = {
        "/proc/net/snmp" = "no";
        "/proc/net/snmp6" = "no";
        "/proc/net/ip_vs/stats" = "no";
        "/proc/net/stat/synproxy" = "no";
        "/proc/net/stat/nf_conntrack" = "no";
    };
  };
}
