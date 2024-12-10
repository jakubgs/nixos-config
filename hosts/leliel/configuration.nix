{ channels, pkgs, lib, ... }:

# This image can be built using nixos-generate.
# https://github.com/nix-community/nixos-generators
{
  imports = [
    #"${channels}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/nfs.nix
    ../../roles/autofs.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/gossa.nix
    ../../roles/landing.nix
    ../../roles/distbuild.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    # Downclocking to reduce temperatures
    #populateCmd = ''
    #  cat ${./config.txt} >> firmware/config.txt
    #'';
  };

  # Kernel configuration
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
    hostId = "cf51a179";
    useDHCP = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # SMART won't work on Raspberry Pi
  services.smartd.enable = lib.mkForce false;

  # Enable sound.
  boot = { # fix for USB not being default card
    extraModprobeConfig = "options snd_usb_audio index=0";
    blacklistedKernelModules = [ "snd_hda_intel" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";

  # Packages
  environment.systemPackages = with pkgs; [ libraspberrypi ];

  # Fix for USB sound issues, doesn't seem to work
  # cat /sys/module/usbcore/parameters/autosuspend
  environment.etc."modprobe.d/nixos.conf".text = ''
    options usbcore autosuspend=-1
  '';
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';
}
