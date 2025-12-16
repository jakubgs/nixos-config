# Bootloader

The best available bootloader is [EDK2 UEFI firmware for Rockchip RK3588 platforms](https://github.com/edk2-porting/edk2-rk3588). The [`0.9.1`](https://github.com/edk2-porting/edk2-rk3588/releases/tag/v0.9.1) release is confirmed working.

In order to flash this bootloader we'll need to download two files:

* [`rk3588_spl_loader_v1.15.113.bin`](https://dl.radxa.com/rock5/sw/images/loader/rock-5b/release/rk3588_spl_loader_v1.15.113.bin) - SPI bootloader image.
* [`rock-5b_UEFI_Release_v0.9.1.img`](https://github.com/edk2-porting/edk2-rk3588/releases/download/v0.9.1/rock-5b_UEFI_Release_v0.9.1.img) - UEFI bootloader image.

The device needs to be put into [Markrom mode](https://wiki.radxa.com/Rock5/install/spi#3.29_Boot_the_board_to_Maskrom_mode) which requires connecting to the device via power USB-C and pressing the button in the corner below GPIO conector.

Disable USB auto-suspend to avoid errors like `Creating Comm Object failed!`:
```
 > echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend
```
Then use the [`rkdeveloptool`](https://wiki.radxa.com/Rock5/install/rockchip-flash-tools) tool in version `1.32` or higher as described in [SPI flashing documentation](https://wiki.radxa.com/Rock5/install/spi):
```
 > nix-shell -p rkdeveloptool

[nix-shell:~/rk3588]$ rkdeveloptool --version
rkdeveloptool ver 1.32

[nix-shell:~/rk3588]$ sudo rkdeveloptool db rk3588_spl_loader_v1.08.111.bin
Downloading bootloader succeeded.

[nix-shell:~/rk3588]$ sudo rkdeveloptool wl 0 rock-5b_UEFI_Release_v0.9.1.img
Write LBA from file (100%)

[nix-shell:~/rk3588]$ sudo rkdeveloptool rb
```
Now the device has a graphical bootloader available when pressing `Escape` at boot time:

![Bootloader Menu](./bootloader.png)
