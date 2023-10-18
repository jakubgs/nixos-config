{ pkgs, lib, ... }:

pkgs.linuxPackagesFor (pkgs.linux_6_5.override {
  kernelPatches = [
    { name = "rk3588s_nanopi_r6_dts";
      patch = ./rk3588s_nanopi_r6_dts.patch; }
  ];

  # Enable more debugging.
  structuredExtraConfig = with lib.kernel; {
    DEBUG_KERNEL      = yes;
    DEBUG_LL          = yes;
    DEBUG_UART_8250   = yes;
    BACKTRACE_VERBOSE = yes;
  };
})
