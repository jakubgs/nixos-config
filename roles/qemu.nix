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
    onBoot = "ignore";
    onShutdown = "shutdown";

    qemu = {
      runAsRoot = true;
      package = pkgs.qemu_kvm;
      ovmf = { enable = true; };
    };
  };

  users.users.jakubgs.extraGroups = [ "libvirtd" ];
}
