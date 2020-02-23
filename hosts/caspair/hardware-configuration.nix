# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AAC8-04CC";
      fsType = "vfat";
    };

  fileSystems."/mnt/melchior" =
    { device = "/nix/store/h1k64i2brywjbxpj8j4zd1cmlmflka2y-melchior";
      fsType = "autofs";
    };

  fileSystems."/mnt/data" =
    { device = "DATA/data";
      fsType = "zfs";
    };

  fileSystems."/mnt/music" =
    { device = "DATA/music";
      fsType = "zfs";
    };

  fileSystems."/mnt/git" =
    { device = "DATA/git";
      fsType = "zfs";
    };

  fileSystems."/mnt/mobile" =
    { device = "DATA/mobile";
      fsType = "zfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
