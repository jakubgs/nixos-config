{ pkgs, ... }:

pkgs.linuxPackagesFor (
  let
    base_kernel = pkgs.linuxKernel.kernels.linux_6_1;
  in pkgs.linuxKernel.manualConfig {
    inherit (pkgs) lib stdenv;
    inherit (base_kernel) src;

    version = "${base_kernel.version}";
    configfile = ./kernel.config;

    kernelPatches = [
      { name = "pcie-rockchip-bus-scan-delay";
        patch = ./pcie-rockchip-bus-scan-delay.patch; }
    ];

    allowImportFromDerivation = true;
  }
)
