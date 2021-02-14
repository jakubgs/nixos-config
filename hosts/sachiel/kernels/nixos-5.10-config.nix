{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_5_10;
  boot.kernelPatches = [{
    name = "pcie-rockchip-config.patch";
    patch = null;
    extraConfig = ''
      LOCALVERSION_AUTO n
      COMPILE_TEST y
      NVME_CORE y
      BLK_DEV_NVME y
      NVME_MULTIPATH y
      PCIE_ROCKCHIP y
      PCIE_ROCKCHIP_HOST y
      PCIE_ROCKCHIP_EP y
      ROCKCHIP_THERMAL y
      ROCKCHIP_LVDS y
      ROCKCHIP_MBOX y
      DEVFREQ_EVENT_ROCKCHIP_DFI y
      ROCKCHIP_SARADC y
      PHY_ROCKCHIP_DP y
      PHY_ROCKCHIP_INNO_HDMI y
      PHY_ROCKCHIP_INNO_USB3 y
      PHY_ROCKCHIP_PCIE y
      PHY_ROCKCHIP_USB y
    '';
  }];
}
