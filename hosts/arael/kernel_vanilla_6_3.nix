{ lib, buildLinux, fetchurl, ... }@args:

buildLinux (args // rec {
  version = "6.3.13";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = lib.versions.pad 3 version;

  # branchVersion needs to be x.y
  extraMeta.branch = lib.versions.majorMinor version;

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
    sha256 = "1ywijjhf19bciip75ppzjjh7bkadd449jr64yg2j5049w9h0aipa";
  };

  kernelPatches = [
    { name = "nanopi_r6s_rk3588s";
      patch = ./patches/nanopi_r6s_rk3588s.patch; }
    { name = "export_neon_symbols_as_gpl";
      patch = ./patches/export_neon_symbols_as_gpl_6_3.patch; }
  ];

  # Enable more debugging.
  structuredExtraConfig = {
    DEBUG_KERNEL = lib.kernel.yes;
    DEBUG_LL = lib.kernel.yes;
    DEBUG_UART_8250 = lib.kernel.yes;
    BACKTRACE_VERBOSE = lib.kernel.yes;
  };
} // (args.argsOverride or { }))
