{ pkgs, lib, ... }:

pkgs.linuxPackagesFor (
  let
    base_kernel = pkgs.linuxKernel.kernels.linux_testing;
  in pkgs.linuxKernel.manualConfig {
    inherit (pkgs) lib stdenv;
    inherit (base_kernel) src;

    version = "${base_kernel.version}";

    configfile = ./kernel.config;

    kernelPatches = [
      { name = "rk3588s_nanopi_r6_dts";
        patch = ./rk3588s_nanopi_r6_dts.patch; }
      { name = "rk3588s_nanopi_r6_dts_fix";
        patch = ./rk3588s_nanopi_r6_dts_fix.patch; }
    ];

    allowImportFromDerivation = true;
  }
)
