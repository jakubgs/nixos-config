{ pkgs, lib, ... }:

let
  ftpUser = "anon";
  listenPort = 9999;
  pasvPorts = {
    min = 51000;
    max = 51100;
  };
in {
  # Service - WARNING: Open to public!
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    #localUsers = true;
    chrootlocalUser = true;
    allowWriteableChroot = true;
    anonymousUser = true;
    anonymousUploadEnable = true;
    anonymousMkdirEnable = true;
    anonymousUserNoPassword = true;
    anonymousUserHome = "/var/tmp/ftp";
    extraConfig = ''
      listen_port=${builtins.toString listenPort}
      pasv_enable=YES
      pasv_min_port=${builtins.toString pasvPorts.min}
      pasv_max_port=${builtins.toString pasvPorts.max}
    '';
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ listenPort ];
  networking.firewall.allowedTCPPortRanges = [
    { from = pasvPorts.min; to = pasvPorts.max; }
  ];
}
