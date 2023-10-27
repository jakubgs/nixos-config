{ pkgs, ... }:

{
  # Systemd in initrd. Useful for debugging boot issues.
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
}
