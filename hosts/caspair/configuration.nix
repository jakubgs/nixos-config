{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/smart.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/network.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/desktop.nix
    ../../roles/bluetooth.nix
    ../../roles/physlock.nix
    ../../roles/printer.nix
    ../../roles/gaming.nix
    ../../roles/docker.nix
    ../../roles/zerotier.nix
    ../../roles/yubikey.nix
    ../../roles/syncthing.nix
    ../../roles/work.nix
    ../../roles/docs.nix
    ../../roles/qemu.nix
    ../../roles/netdata.nix
    ../../roles/landing.nix
    ../../roles/crypto.nix
    ../../roles/optical.nix
    ../../roles/dnsmasq.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  # Sensors
  boot.kernelModules = [ "nct6775" "coretemp" "i2c-1" ];

  networking = {
    hostName = "caspair";
    hostId = "9fbd8b5d";
    useDHCP = false;
    interfaces = {
      eno1 = { useDHCP = true; };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Video
  services.xserver.videoDrivers = [ "intel" "nvidia" ];

  # Power Managemtn
  powerManagement.cpuFreqGovernor = "performance";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
