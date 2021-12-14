{ pkgs, ... }:

{
  boot = {
    kernelParams = [ "amd_iommu=on" "pcie_aspm=off" ];
    kernelModules = [ "kvm-intel" ];
  };

  environment.systemPackages = with pkgs; [
    virtmanager
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = true;
    qemuPackage = pkgs.qemu_kvm;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  users.users.jakubgs.extraGroups = [ "libvirtd" ];
}
