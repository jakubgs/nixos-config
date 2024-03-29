{ secret, ... }:

let
  listenPort = 9999;
  pasvPorts = {
    min = 51000;
    max = 51001;
  };
in {
  age.secrets."service/vsftpd/pass" = {
    file = ../secrets/service/vsftpd/pass.age;
  };

  # User
  users.extraUsers.anon = {
    createHome = true;
    isNormalUser = true;
    hashedPasswordFile = secret "service/vsftpd/pass";
    extraGroups = [ "ftp" ];
  };

  # Service - WARNING: Open to public!
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    chrootlocalUser = true;
    allowWriteableChroot = true;
    userlistEnable = true;
    userlist = [ "anon" ];
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
