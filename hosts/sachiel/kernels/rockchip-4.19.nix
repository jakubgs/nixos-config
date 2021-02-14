{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_4_19.override {
    argsOverride = rec {
      src = pkgs.fetchzip {
        url = "https://github.com/rockchip-linux/kernel/archive/08e8386122b77fdbf16779195cf722f4b8c02384.zip";
        sha256 = "045dxqaaqdq7vi72hw8ylisrgx7gkrafvh3iqvbrmd687jz233r2";
      };
      version = "4.19.111";
      modDirVersion = "4.19.111";
    };
  });
}
