{ config, pkgs, channels, ... }:

{
  imports = [
    channels.hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
    ./hardware-configuration.nix
    ../../roles/base
    ../../roles/desktop
    ../../roles/laptop.nix
    ../../roles/syncthing.nix
    ../../roles/tailscale.nix
    ../../roles/work.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Scrub to find errors
  services.zfs.autoScrub = {
    pools = [ "rpool" ];
  };

  networking.hostId = "e87975cc";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  hardware.pulseaudio.enable = true;

  # Power auto tuning on startup
  powerManagement.powertop.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
