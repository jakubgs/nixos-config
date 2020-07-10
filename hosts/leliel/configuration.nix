{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/docker.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = ["cma=64M" "console=tty0"];

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  # Filesystems
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # Networking
  networking.hostName = "leliel";

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.03";
}
