# Description

Since the kernel has to be compiled with `` and `` baked-in due to PCI-E trainig timeout we might as well slim down the kernel config to limit the build time and size.

# Config

The [`kernel.config`](./kernel.config) file was generated using `make menuconfig`:
```
make menuconfig ARCH=arm64
```
Notice the expliccit use of `ARCH=arm64` which prevents the editor from applying configuration specific to the current host architecture.

## Chipsets and Modules

| Config                | Device Driver                    | Comment |
|-----------------------|----------------------------------|---------|
| `COMMON_CLK_ROCKCHIP` | Rockchip clock controller common |         |
| `DW_WATCHDOG`         | Synopsys DesignWare watchdog     | `dw_wdt ff848000.watchdog` |
| `NVMEM_ROCKCHIP_OTP`  | Rockchip OTP controller support  |         |
| `PCIE_ROCKCHIP_HOST`  | Rockchip PCIe host controller    |         |
| `PCIE_ROCKCHIP`       | Rockchip PCIe host controller    |         |
| `PHY_ROCKCHIP_PCIE`   | Rockchip PCIe PHY Driver         | `phy-pcie-phy.5: Looking up phy-supply` |
| `PINCTRL_ROCKCHIP`    | Rockchip gpio and pinctrl driver |         |
| `PWM_ROCKCHIP`        | Rockchip PWM support             |         |
| `ROCKCHIP_PHY`        | Rockchip Ethernet PHYs           | `rk_gmac-dwmac fe300000.ethernet eth0` |
| `ROCKCHIP_THERMAL`    | Rockchip thermal driver          | `rockchip-thermal ff260000.tsadc` |
| `ROCKCHIP_TIMER`      | Rockchip timer driver            |         |
| `RTC_DRV_RK808`       | Rockchip RK805/808/809/817/818 RTC | `rk808-rtc: setting system clock to` |
| `MFD_RK808`           | Rockchip RK805/808/809/817/818 Power Management Chip | |
| `REGULATOR_RK808`     | Rockchip RK805/808/809/817/818 Power regulators      | |
| `SND_SOC_ROCKCHIP`    | ASoC support for Rockchip        | `asoc-simple-card rt5652-sound: ASoC` |
