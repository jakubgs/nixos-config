{ pkgs, channels, lib, ... }:

{
  imports = [
    channels.hardware.nixosModules.lenovo-thinkpad-x390
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../roles/base
    ../../roles/desktop
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  # Sensors
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Network
  networking = {
    hostId = "27aa0635";
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

  # Power Managemtn
  powerManagement.cpuFreqGovernor = "performance";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
