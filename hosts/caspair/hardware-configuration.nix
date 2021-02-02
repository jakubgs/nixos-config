# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9C9E-FCCC";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/home/sochan/.local/share/Steam" =
    { device = "rpool/steam";
      fsType = "zfs";
    };

  fileSystems."/mnt/music" =
    { device = "DATA/music";
      fsType = "zfs";
    };

  fileSystems."/mnt/mobile" =
    { device = "DATA/mobile";
      fsType = "zfs";
    };

  fileSystems."/mnt/data" =
    { device = "DATA/data";
      fsType = "zfs";
    };

  fileSystems."/mnt/photos" =
    { device = "DATA/photos";
      fsType = "zfs";
    };

  fileSystems."/mnt/git" =
    { device = "DATA/git";
      fsType = "zfs";
    };

  #fileSystems."/git" =
  #  { device = "/mnt/git";
  #    fsType = "none";
  #    options = [ "bind" ];
  #  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
