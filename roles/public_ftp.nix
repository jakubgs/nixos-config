{ config, secret, ... }:

let
  ftpPort = 9999;
  pasvPorts = {
    min = 51000;
    max = 51001;
  };
in {
  # Firewall
  networking.firewall.allowedTCPPorts = [ ftpPort 80 ];
  networking.firewall.allowedTCPPortRanges = [
    { from = pasvPorts.min; to = pasvPorts.max; }
  ];

  # User
  users.extraUsers.anon = {
    createHome = true;
    isNormalUser = true;
    hashedPassword = secret "service/vsftpd/pass";
    extraGroups = [ "ftp" ];
  };

  # Service - WARNING: Open to public!
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localRoot = "/mnt/ftp";
    localUsers = true;
    chrootlocalUser = true;
    allowWriteableChroot = true;
    userlistEnable = true;
    userlist = [ "anon" ];
    extraConfig = ''
      listen_port=${builtins.toString ftpPort}
      pasv_enable=YES
      pasv_min_port=${builtins.toString pasvPorts.min}
      pasv_max_port=${builtins.toString pasvPorts.max}
    '';
  };

  services.nginx = {
    enable = true;
    enableReload = true;

    virtualHosts = {
      "f.jgs.pw" = {
        serverName = "f.jgs.pw";
        locations = {
          "/" = {
            root = "/mnt/ftp";
            extraConfig = "autoindex on;";
          };
        };
      };
    };
  };
}
