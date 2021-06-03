{ pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
  ];

  boot.kernelPackages = pkgs.linuxPackages_5_11;
  boot.kernelPatches = [{
    name = "pcie-rockchip-config.patch";
    patch = null;
    extraConfig = ''
      NVME_CORE y
      NVME_MULTIPATH y
      BLK_DEV_NVME y
      PCIE_ROCKCHIP y
      PHY_ROCKCHIP_PCIE y
    '';
  }];

  services.mingetty.serialSpeed = [ 1500000 115200 ];

  nixpkgs.config.allowUnsupportedSystem = true;

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= sochan@lilim"
  ];
}
