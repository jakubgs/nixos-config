{ config, pkgs, lib, ... }:
{
  imports = [
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
  fileSystems = {
      # There is no U-Boot on the Pi 4 (yet) -- the firmware partition has to be mounted as /boot.
      "/boot" = {
          device = "/dev/disk/by-label/FIRMWARE";
          fsType = "vfat";
      };
      "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
      };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # Networking
  networking.hostName = "leliel";

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # Nix
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.03";
}
