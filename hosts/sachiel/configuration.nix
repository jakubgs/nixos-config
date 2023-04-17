{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/landing.nix
    ../../roles/nfs.nix
    ../../roles/samba.nix
    ../../roles/gossa.nix
    ../../roles/music.nix
    ../../roles/torrent.nix
    ../../roles/mikrotik.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    configurationLimit = 30;
  };
  # Fix for not detecting the NVMe SSD
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
    structuredExtraConfig = with lib.kernel; {
      PHY_ROCKCHIP_PCIE  = yes;
      PCIE_ROCKCHIP_HOST = yes;
    };
  });

  # Set serial console settings
  boot.kernelParams = [ "console=ttyS2,1500000" ];
  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  # Systemd in initrd. EXPERIMENTAL
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = true;
    storePaths = with pkgs; [ util-linux pciutils ];
    extraBin = {
      fdisk = "${pkgs.util-linux}/bin/fdisk";
      lsblk = "${pkgs.util-linux}/bin/lsblk";
      lspci = "${pkgs.pciutils}/bin/lspci";
    };
  };

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
  system.stateVersion = "20.09";
}
