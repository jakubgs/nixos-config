{ config, pkgs, channels, ... }:

{
  imports = [
    channels.hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/network.nix
    ../../roles/dnsmasq.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/desktop.nix
    ../../roles/laptop.nix
    ../../roles/bluetooth.nix
    ../../roles/physlock.nix
    ../../roles/docker.nix
    ../../roles/music.nix
    ../../roles/zerotier.nix
    ../../roles/yubikey.nix
    ../../roles/crypto.nix
    ../../roles/work.nix
    ../../roles/docs.nix
    ../../roles/qemu.nix
    ../../roles/syncthing.nix
    ../../roles/landing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Scrub to find errors
  services.zfs.autoScrub = {
    pools = [ "rpool" ];
  };

  networking = {
    hostName = "lilim";
    hostId = "e87975cc";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "pl";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Power auto tuning on startup
  powerManagement.powertop.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
