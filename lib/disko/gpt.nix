{
  mkPart = priority: size: name: {
    inherit priority size name;
  };

  mkEFI = priority: size: name: {
    inherit priority size name;
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "umask=0077" ];
    };
  };

  mkSwap = priority: size: name: {
    inherit priority size name;
    content = {
      type = "swap";
      discardPolicy = "both";
      resumeDevice = true;
      randomEncryption = true;
      priority = 100; # prefer to encrypt as long as we have space for it
    };
  };

  mkZpool = priority: size: name: {
    inherit priority size name;
    content = {
      type = "zfs";
      pool = "rpool";
    };
  };
}
