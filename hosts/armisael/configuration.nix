{ pkgs, channels, ... }:

{
  imports = [
    channels.hardware.nixosModules.lenovo-thinkpad-t480s
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../roles/base
    ../../roles/desktop
    ../../roles/laptop
    ../../roles/printer.nix
    ../../roles/syncthing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # Sensors
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Network
  networking.hostId = "9e8841ba";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Power Managemtn
  powerManagement.cpuFreqGovernor = "performance";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
