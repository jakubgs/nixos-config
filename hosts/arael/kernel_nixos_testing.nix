{ pkgs, lib, ... }:

pkgs.linuxPackagesFor (pkgs.linux_testing.override {
  kernelPatches = [
    { name = "rk3588s_nanopi_r6_dts";
      patch = ./rk3588s_nanopi_r6_dts.patch; }
  ];

  configfile = ./kernel.config;
})
