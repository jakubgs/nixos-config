{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/mikrotik.nix
    ../../roles/iperf.nix
    ../../roles/nfs.nix
    ../../roles/gossa.nix
    ../../roles/samba.nix
    ../../roles/syncthing.nix
    ../../roles/torrent.nix
    ../../roles/invidious.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    timeout = 5;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    grub.enable = false;
  };

  # Lock kernel version.
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  networking = {
    hostId = "892cff1c";
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}
