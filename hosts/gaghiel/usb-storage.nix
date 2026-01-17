{ ... }:

{
  fileSystems."/mnt/data" =
    { device = "USB-DATA/data";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/git" =
    { device = "USB-DATA/git";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/mobile" =
    { device = "USB-DATA/mobile";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/music" =
    { device = "USB-DATA/music";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/photos" =
    { device = "USB-DATA/photos";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/grzegorz" =
    { device = "USB-DATA/grzegorz";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };
}
