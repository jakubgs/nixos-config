{ pkgs, ... }:

let
  vid = "0764";
  pid = "0501";
  password = "TODO";
in {
  environment.systemPackages = with pkgs; [ nut ];

  nixpkgs.overlays = [
    (final: prev: {
      nut = prev.nut.overrideAttrs (_: {
        configureFlags = [
          "--with-all"
          "--with-ssl"
          "--without-snmp" # Until we have it ...
          "--without-powerman" # Until we have it ...
          "--without-cgi"
          "--without-hal"
          "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
          "--with-udev-dir=$(out)/etc/udev"
          "--libdir=/run/current-system/sw/lib"
        ];
      });
    })
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="${vid}", ATTRS{idProduct}=="${pid}", MODE="664", GROUP="nut", OWNER="nut"
  '';

  power.ups = {
    enable = true;
    mode = "standalone";
    ups.powerwalker = {
      driver = "usbhid-ups";
      port = "auto";
      description = "PowerWalker VI R1U 750VA";
      directives = [
        "vendorid = ${vid}"
        "productid = ${pid}"
      ];
    };
  };

  users = {
    users.nut = {
      isSystemUser = true;
      group = "nut";
      # it does not seem to do anything with this directory
      # but something errored without it, so whatever
      home = "/var/lib/nut";
      createHome = true;
    };
    groups.nut = {};
  };

  systemd.services.upsd.serviceConfig = {
    User = "nut";
    Group = "nut";
  };

  systemd.services.upsdrv.serviceConfig = {
    User = "nut";
    Group = "nut";
  };

  environment.etc = {
    # all this file needs to do is exist
    upsdConf = {
      text = "";
      target = "nut/upsd.conf";
      mode = "0440";
      group = "nut";
      user = "nut";
    };
    upsdUsers = {
      # update upsmonConf MONITOR to match
      text = ''
      [upsmon]
        password = ${password}
        upsmon master
      '';
      target = "nut/upsd.users";
      mode = "0440";
      group = "nut";
      user = "nut";
    };
    # RUN_AS_USER is not a default
    # the rest are from the sample
    # grep -v '#' /nix/store/8nciysgqi7kmbibd8v31jrdk93qdan3a-nut-2.7.4/etc/upsmon.conf.sample
    upsmonConf = {
      text = ''
        RUN_AS_USER nut

        MINSUPPLIES 1
        SHUTDOWNCMD "shutdown -h 0"
        POLLFREQ 5
        POLLFREQALERT 5
        HOSTSYNC 15
        DEADTIME 15
        RBWARNTIME 43200
        NOCOMMWARNTIME 300
        FINALDELAY 5
        MONITOR cyberpower@localhost 1 upsmon ${password} master
      '';
      target = "nut/upsmon.conf";
      mode = "0444";
    };
  };

  systemd.tmpfiles.rules = [
    "d '/var/lib/nut/'              0700 nut nogroup - -"
  ];
}
