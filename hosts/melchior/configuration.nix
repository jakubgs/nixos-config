{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/nfs.nix
    ../../roles/samba.nix
    ../../roles/music.nix
    ../../roles/locate.nix
    ../../roles/torrent.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/netdata.nix
    ../../roles/landing.nix
    ../../services/transmission.nix
    ../../services/transmission-watch.nix
  ];

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];

  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "SYSTEM" "DATA" "MEDIA" ];
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
    interfaces.enp3s0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  boot = { # fix for USB not being default card
    extraModprobeConfig = "options snd_usb_audio index=0";
    blacklistedKernelModules = [ "snd_hda_intel" ];
  };

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09";
}
