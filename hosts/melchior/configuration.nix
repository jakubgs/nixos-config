{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/samba.nix
    ../../roles/music.nix
    ../../roles/locate.nix
    ../../roles/torrent.nix
    ../../roles/zerotier.nix
    ../../roles/netdata.nix
    ../../services/transmission.nix
    ../../services/transmission-watch.nix
  ];

  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];

  # Enable ZFS support
  networking.hostId = "e5acabaa";
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";
  services.zfs.autoScrub.pools = [ "MEDIA" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.device = "/dev/sdh";
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.useOSProber = false;

  networking.hostName = "melchior";
  networking.domain = "magi";
  networking.interfaces.enp3s0.useDHCP = true;

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
  
  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09";
}
