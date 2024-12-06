{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
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
    ../../roles/music.nix
    ../../roles/zerotier.nix
    ../../roles/tailscale.nix
    ../../roles/yubikey.nix
    ../../roles/syncthing.nix
    ../../roles/restic.nix
    ../../roles/work.nix
    ../../roles/docs.nix
    ../../roles/landing.nix
    ../../roles/optical.nix
    ../../roles/dnsmasq.nix
    ../../roles/qemu.nix
    ../../roles/builder.nix
    ../../roles/crypto.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  # Resume
  systemd.sleep.extraConfig = "HibernateMode=reboot";

  # Sensors
  boot.kernelModules = [ "nct6775" "coretemp" "i2c-1" ];
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking = {
    hostId = "9fbd8b5d";
    useDHCP = false;
    interfaces = {
      eno1 = { useDHCP = true; };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";
  # Avoid difference when dual-booting Windows.
  time.hardwareClockInLocalTime = true;

  # Video
  hardware.nvidia.open = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Power Managemtn
  powerManagement.cpuFreqGovernor = "performance";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

  systemd.coredump.enable = true;
}
