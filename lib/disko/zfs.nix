{
  mkDataSet = mountpoint: quota: snapshot: options: {
    inherit mountpoint;
    type = "zfs_fs";
    options = {
      inherit quota;
      "reservation" = quota;
      "canmount" = "noauto";
      "com.sun:auto-snapshot" = if snapshot then "true" else "false";
    } // options;
  };

  rootFsOptions = {
    canmount = "off";
    mountpoint = "none";
    compression = "zstd";
    dnodesize = "auto";
    normalization = "formD";
    atime = "off";
    xattr = "sa";
  };

  encryptedOpts = {
    canmount = "off";
    encryption = "aes-256-gcm";
    keylocation = "prompt";
    keyformat = "passphrase";
  };
}
