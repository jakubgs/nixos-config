# Bootloader

The best available bootloader is [EDK2 UEFI firmware for Rockchip RK3588 platforms](https://github.com/edk2-porting/edk2-rk3588).

Unfortunately currently offical release does not support Rock 5C, but as seen [in this issue](https://github.com/edk2-porting/edk2-rk3588/issues/152) this fork does:

* <https://github.com/kwankiu/edk2-rk3588>

In order to flash this bootloader we'll need to download the image:

* [`rock-5b_UEFI_Release_v0.9.1.img`](https://github.com/kwankiu/edk2-rk3588/releases/download/v1.1/rock-5c_UEFI_Release_v1.1.img)

Write it to the eMMC device using `dd`:
```
dd if=rock-5c_UEFI_Release_v1.1.img of=/dev/mmcblk0p1 bs=512 skip=64 conv=notrunc
```
> :warning: This assumes existence of first `uboot` partition.

![Bootloader Menu](../arael/bootloader.png)
