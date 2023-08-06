{ lib, buildLinux, fetchFromGitHub, ... }@args:

buildLinux (args // rec {
  kernelPatches = [];
  version = "5.10.160";
  modDirVersion = "5.10.160";
  defconfig = "rockchip_linux_defconfig";

  # Disable broken modules
  structuredExtraConfig = {
    XFS_FS = lib.kernel.no;
    WL_ROCKCHIP = lib.kernel.no;
  };

  # do not automatically try to load other modules
  autoModules = false;

  src = fetchFromGitHub {
    owner = "friendlyarm";
    repo = "kernel-rockchip";
    rev = "5e86b5cbaac7f1751b464f50e54255de881cced0"; # nanopi5-v5.10.y_op
    sha256 = "sha256-l0+8S81fbf2LVhjqz9tYm7SvfmwB373xagLlfvJIOm0=";
  };
} // (args.argsOverride or {}))
