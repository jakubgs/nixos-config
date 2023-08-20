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
      patch = ./nanopi_r6s_rk3588s.patch; }
  ];
} // (args.argsOverride or { }))
