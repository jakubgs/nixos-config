# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/secret/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9C9E-FCCC";
      fsType = "vfat";
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/6285b12d-6a5f-451c-b6c1-e899a14d609e";
      fsType = "ext4";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/steam" =
    { device = "/dev/disk/by-uuid/25dbbbda-ab15-4f4c-ac54-36e74837b7ca";
      fsType = "ext4";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/windows" =
    { device = "/dev/disk/by-uuid/56BCBB0CBCBAE5A1";
      fsType = "ntfs-3g";
      options = [ "noauto" "nofail" "uid=1000" "gid=1000" ];
    };

  fileSystems."/mnt/vms" =
    { device = "DATA/vms";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/games" =
    { device = "DATA/games";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/mobile" =
    { device = "DATA/mobile";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/music" =
    { device = "DATA/music";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/data" =
    { device = "DATA/data";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/photos" =
    { device = "DATA/photos";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/torrent" =
    { device = "DATA/torrent";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/mnt/git" =
    { device = "DATA/git";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/git" =
    { device = "/mnt/git";
      fsType = "none";
      options = [ "noauto" "nofail" "bind" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/678b584f-bb41-4aa2-95b4-8350b2dd91f2"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
