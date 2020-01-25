{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/vars.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/nfs.nix
    ../../roles/samba.nix
    ../../roles/music.nix
    ../../roles/locate.nix
    ../../roles/torrent.nix
    ../../roles/zerotier.nix
    ../../roles/netdata.nix
    ../../roles/nextcloud.nix
    ../../services/transmission.nix
    ../../services/transmission-watch.nix
  ];

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];
  boot.kernelParams = [ "ipv6.disable=1" ];

  # Enable ZFS support
  # WARNING: All mountpoints need to be set to 'legacy'
  boot.supportedFilesystems = [ "zfs" ];
  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "SYSTEM" "DATA" "MEDIA" ];
  };
  # Snapshot daily
  services.zfs.autoSnapshot = {
    enable = true;
    monthly = 6;
    weekly = 2;
    daily = 14;
    hourly = 0;
    frequent = 0;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.devices = [
    "/dev/disk/by-id/ata-SanDisk_SDSSDA120G_173025801877"
    "/dev/disk/by-id/ata-SanDisk_SDSSDA120G_173025803524"
  ];
  # To avoid some boot errors
  boot.loader.grub.copyKernels = true;

  networking = {
    hostName = "melchior";
    hostId = "e5acabaa";
    domain = "magi";
    search = [ "magi.blue" ];
    enableIPv6 = false;
    interfaces.enp3s0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  boot.extraModprobeConfig = ''
    options snd_usb_audio index=0
    options snd_hda_intel index=1
  '';

  # Define "global" variables, see roles/vars.nix
  vars = {
    ports = {
      mpd          = 6600;
      netdata      = 8000;
      ympd         = 8001;
      nextcloud    = 8002;
      transmission = 9091;
    };
  };
  
  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09";
}
