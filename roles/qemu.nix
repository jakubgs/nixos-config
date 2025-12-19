{ pkgs, ... }:

{
  boot = {
    kernelParams = [ "amd_iommu=on" "pcie_aspm=off" ];
    kernelModules = [ "kvm-intel" ];
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    qemu-utils
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";

    qemu = {
      runAsRoot = true;
      package = pkgs.qemu_kvm;
    };
  };

  # Clipboard sharing - requires spice-guest-tools
  services.spice-vdagentd.enable = true;

  users.users.jakubgs.extraGroups = [ "libvirtd" ];
}
