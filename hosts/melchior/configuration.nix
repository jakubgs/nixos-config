{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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
    ../../roles/landing.nix
  ];

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.devices = [
    "/dev/disk/by-id/ata-SanDisk_SDSSDA120G_173025801877"
    "/dev/disk/by-id/ata-SanDisk_SDSSDA120G_173025803524"
  ];
  # To avoid some boot errors
  boot.loader.grub.copyKernels = true;

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  networking = {
    hostId = "e5acabaa";
    interfaces.enp3s0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  boot = { # fix for USB not being default card
    extraModprobeConfig = "options snd_usb_audio index=0";
    blacklistedKernelModules = [ "snd_hda_intel" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
