{ pkgs, lib, ... }:

pkgs.linuxPackagesFor (pkgs.linux_6_5.override {
  kernelPatches = [
    { name = "nanopi_r6s_rk3588s";
      patch = ./nanopi_r6s_rk3588s.patch; }
  ];

  # Enable more debugging.
  structuredExtraConfig = with lib.kernel; {
    DEBUG_KERNEL      = yes;
    DEBUG_LL          = yes;
    DEBUG_UART_8250   = yes;
    BACKTRACE_VERBOSE = yes;
  };
})
