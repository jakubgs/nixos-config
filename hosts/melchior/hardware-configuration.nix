# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "mpt3sas" "xhci_pci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "SYSTEM";
      fsType = "zfs";
    };

  fileSystems."/mnt/git" =
    { device = "DATA/git";
      fsType = "zfs";
    };

  fileSystems."/mnt/torrent" =
    { device = "MEDIA/torrent";
      fsType = "zfs";
    };

  fileSystems."/mnt/usb_backup" =
    { device = "/dev/disk/by-uuid/bef2843c-7e60-4250-aeef-9f8e48427d4f";
      fsType = "ext4";
    };

  fileSystems."/mnt/data" =
    { device = "DATA/data";
      fsType = "zfs";
    };

  fileSystems."/mnt/music" =
    { device = "DATA/music";
      fsType = "zfs";
    };

  fileSystems."/git" =
    { device = "/mnt/git";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/mnt/nextcloud" =
    { device = "DATA/nextcloud";
      fsType = "zfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  # High-DPI console
  i18n.consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
