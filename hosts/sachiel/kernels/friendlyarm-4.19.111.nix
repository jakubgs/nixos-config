{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_4_19.override {
    argsOverride = rec {
      src = pkgs.fetchzip {
        url = "https://github.com/friendlyarm/kernel-rockchip/archive/2e5b78e90fe450aca212af67d7ea831a364da9a4.zip";
        sha256 = "045dxqaaqdq7vi72hw8ylisrgx7gkrafvh3iqvbrmd687jz233r2";
      };
      version = "4.19.111";
      modDirVersion = "4.19.111";
    };
  });
}
