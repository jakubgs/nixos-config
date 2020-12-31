{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/smart.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/nfs.nix
    ../../roles/music.nix
    ../../roles/autofs.nix
    ../../roles/docker.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/landing.nix
    ../../roles/torrent.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
    # Downclocking to reduce temperatures
    firmwareConfig = ''
      # Default: 1500
      arm_freq_max=1700
      # Default: 600
      arm_freq_min=600
      # Default: 60
      temp_soft_limit=65
    '';
  };

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = ["cma=64M" "console=tty0"];

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  # Lower power usage and heat generation
  powerManagement.cpuFreqGovernor = "ondemand";

  # Filesystems
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # Networking
  networking = {
    hostName = "leliel";
    hostId = "cf51a179";
    useDHCP = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  # SMART won't work on Raspberry Pi
  services.smartd.enable = lib.mkForce false;

  # Enable sound.
  sound.enable = true;
  boot = { # fix for USB not being default card
    extraModprobeConfig = "options snd_usb_audio index=0";
    blacklistedKernelModules = [ "snd_hda_intel" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";

  # Packages
  environment.systemPackages = with pkgs; [ raspberrypi-tools ];

  # Fix for USB sound issues, doesn't seem to work
  # cat /sys/module/usbcore/parameters/autosuspend
  environment.etc."modprobe.d/nixos.conf".text = ''
    options usbcore autosuspend=-1
  '';
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';
}
