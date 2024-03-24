{ pkgs, lib, config, ... }:

let
  isMounted = path: lib.hasAttr path config.fileSystems;

  makePublicShare = path: {
    name = builtins.baseNameOf path;
    value = {
      inherit path;
      browseable = "yes";
      writeable = "no";
      "guest ok" = "yes";
      "guest only" = "yes";
      "force user" = "nobody";
    };
  };
  makePrivateShare = path: {
    name = builtins.baseNameOf path;
    value = {
      inherit path;
      browseable = "no";
      writeable = "yes";
    };
  };
  shares = {
    public = lib.filter isMounted [
      "/mnt/music"
      "/mnt/photos"
      "/mnt/grzegorz"
    ];
    private = lib.filter isMounted [
      "/mnt/git"
      "/mnt/data"
      "/mnt/torrent"
    ];
  };
in {
  # Tools
  environment.systemPackages = with pkgs; [ samba ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  # Daemon
  services.samba.enable = true;
  services.samba.extraConfig = ''
    netbios name = ${config.networking.hostName}
    name resolve order = bcast host
    load printers = no
    printcap name = /dev/null
    printing = bsd
    guest account = nobody
    map to guest = Bad User
    # Avoid ipv6 bind errors
    bind interfaces only = yes
  '';
  services.samba.shares = with lib; (
    listToAttrs (map makePublicShare shares.public) //
    listToAttrs (map makePrivateShare shares.private)
  );

  # User for /mnt/ania
  users.groups.ania = {
    gid = 1001;
    name = "ania";
  };
  users.users.ania = {
    uid = 1001;
    createHome = true;
    isNormalUser = true;
    useDefaultShell = true;
    group = "ania";
  };
}
