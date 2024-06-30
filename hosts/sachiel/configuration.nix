{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/iperf.nix
    ../../roles/nfs.nix
    ../../roles/samba.nix
    ../../roles/syncthing.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    configurationLimit = 30;
  };
  # Fix for not detecting the NVMe SSD
  boot.kernelPackages = pkgs.linuxPackages_6_1;
  boot.initrd.availableKernelModules = [
    "nvme" "pcie-rockchip-host" "phy-rockchip-pcie"
  ];

  # Set serial console settings
  boot.kernelParams = [ "console=ttyS2,1500000" ];
  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  # Lower power usage and heat generation
  powerManagement.cpuFreqGovernor = "conservative";
  powerManagement.cpufreq.min = 408000;
  powerManagement.cpufreq.max = 1800000;

  # Networking
  networking = {
    hostName = "sachiel";
    hostId = "3cd72605";
    useDHCP = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  boot = { # fix for USB not being default card
    extraModprobeConfig = "options snd_usb_audio index=0";
    blacklistedKernelModules = [ "snd_hda_intel" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
