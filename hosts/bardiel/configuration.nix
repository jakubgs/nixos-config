{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/netdata.nix
    ../../roles/syncthing.nix
    ../../roles/prometheus.nix
    ../../roles/alertmanager.nix
    ../../roles/grafana.nix
    ../../roles/gitweb.nix
    ../../roles/nfs.nix
    ../../roles/gossa.nix
    ../../roles/builder.nix
  ];

  #nix.useSandbox = false;
  boot.zfs.forceImportRoot = false;
  boot.zfs.requestEncryptionCredentials = false;

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    configurationLimit = 5;
    mirroredBoots = [
      {
        devices = ["/dev/disk/by-id/ata-WDC_WD2000FYYZ-01UL1B1_WD-WCC1P1092953"];
        path = "/boot";
      }
      {
        devices = ["/dev/disk/by-id/ata-ST2000NM0033-9ZM175_Z1X12D5D"];
        path = "/boot2";
      }
    ];
  };

  networking = {
    hostName = "bardiel";
    hostId = "4b16a017";
    interfaces.eth0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # Set your time zone.
  time.timeZone = "Europe/Frankfurt";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "21.11";
}
