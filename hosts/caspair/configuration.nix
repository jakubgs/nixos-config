{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base
    ../../roles/desktop
    ../../roles/builder.nix
    ../../roles/optical.nix
    ../../roles/printer.nix
    ../../roles/qemu.nix
    ../../roles/restic.nix
    ../../roles/syncthing.nix
    ../../roles/tailscale.nix
    ../../roles/work.nix
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
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking = {
    hostId = "9fbd8b5d";
    useDHCP = false;
    interfaces = {
      eno1 = { useDHCP = true; };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # 4K screen makes the font too big.
  console.font = lib.mkForce "${pkgs.terminus_font}/share/consolefonts/ter-118n.psf.gz";

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
