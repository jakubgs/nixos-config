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
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
}
