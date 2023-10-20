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
      { name = "fix-clk-divisions";
        patch = ./patches/0010-fix-clk-divisions.patch; }
      { name = "irqchip-fix-its-timeout-issue";
        patch = ./patches/0011-irqchip-fix-its-timeout-issue.patch; }
      { name = "RK3588-Add-Cpufreq-Support";
        patch = ./patches/0023-RK3588-Add-Cpufreq-Support.patch; }
      { name = "Add-RK3588-USB3-Support";
        patch = ./patches/0024-Add-RK3588-USB3-Support.patch; }
      { name = "arm64-dts-rockchip-rk3588-add-sfc-node";
        patch = ./patches/0025-arm64-dts-rockchip-rk3588-add-sfc-node.patch; }
      { name = "rk3588s_nanopi_r6_dts";
        patch = ./patches/rk3588s_nanopi_r6_dts.patch; }
    ];

    allowImportFromDerivation = true;
  }
)
