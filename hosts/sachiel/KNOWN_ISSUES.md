# Description

This is a list of known issues with the NanoPC-T4.

# Issues

## NVMe Link Training Timeout

Currently the SSD NVMe is not detected at boot by default due to a Kernel bug:
```
[    3.150189] rockchip-pcie f8000000.pcie: PCIe link training gen1 timeout!
```
This is caused by too short PCI-E link training time:
```c
	/* 500ms timeout value should be enough for Gen1/2 training */
	err = readl_poll_timeout(rockchip->apb_base + PCIE_CLIENT_BASIC_STATUS1,
				 status, PCIE_LINK_UP(status), 20,
				 500 * USEC_PER_MSEC);
	if (err) {
		dev_err(dev, "PCIe link training gen1 timeout!\n");
		goto err_power_off_phy;
	}
```
https://github.com/torvalds/linux/blob/4b0986a3/drivers/pci/controller/pcie-rockchip-host.c#L330-L339

This results in system not being bootable without patching or special configuration.

### PCI-E Rockchip Module in Initram Image

The simplest way __that works only with some devices__ is including the module in Initrd image:
```nix
boot.initrd.availableKernelModules = [ "nvme" "pcie-rockchip-host" "phy-rockchip-pcie" ];
```
Known to work with __SK hynix PC401 256 GB NVMe__.

### Built-in PCI-E Rockchip Module

Another way to make the NVMe SSD be detected you will need to compile some modules directly into the kernel:
```
PHY_ROCKCHIP_PCIE y
PCIE_ROCKCHIP_HOST y
```
To do this in NixOS configuration use:
```nix
{
  boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.kernelPatches = [{
    name = "pcie-rockchip-config.patch";
    patch = null;
    extraConfig = ''
      PHY_ROCKCHIP_PCIE y
      PCIE_ROCKCHIP_HOST y
    '';
  }];
}
```
It's a good idea to also lock the kernel verison to avoid rebuilds.

### PCI-E ROckchip Module Kernel Patch

The other way is to include the patch that adds support for the `pcie_rk_bus_scan_delay` kernel parameter:

* https://github.com/ayufan-rock64/linux-mainline-kernel/commit/005d53f6519887c24d73e8542be1d258be633169

But that patch is only for `5.9` to `6.2` versions of Linux Kernel.
