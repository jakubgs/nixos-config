# Description

Describes installation process on Rock 5B `israfel` host.

# Bootloader

The best available bootloader is [EDK2 UEFI firmware for Rockchip RK3588 platforms](https://github.com/edk2-porting/edk2-rk3588). The [`0.9.1`](https://github.com/edk2-porting/edk2-rk3588/releases/tag/v0.9.1) release is confirmed working.

In order to flash this bootloader we'll need to download two files:

* [`rk3588_spl_loader_v1.15.113.bin`](https://dl.radxa.com/rock5/sw/images/loader/rock-5b/release/rk3588_spl_loader_v1.15.113.bin) - SPI bootloader image.
* [`rock-5b_UEFI_Release_v0.9.1.img`](https://github.com/edk2-porting/edk2-rk3588/releases/download/v0.9.1/rock-5b_UEFI_Release_v0.9.1.img) - UEFI bootloader image.

The decide needs to be put into [Markrom mode](https://wiki.radxa.com/Rock5/install/spi#3.29_Boot_the_board_to_Maskrom_mode) which requires connecting to the device via power USB-C and pressing the button in the corner below GPIO conector.

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

# Install Image

I used an Armbian 23.8 Bookworm image: <https://www.armbian.com/rock-5b/>

The stock [NixOS `aarch64` image](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux) does not work currently.

Install Nix package manager using [the usual methods](https://nixos.wiki/wiki/Nix_Installation_Guide) and then install `nixos-install-tools`:
```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
nix-env -iA nixos-install-tools
```

# Partitioning

To partition the NVMe the following layout is used:
```sh
format() {
  parted -s --align optimal "$1" -- mklabel gpt;
  parted -s --align optimal "$1" -- mkpart 'EFI'     2MB   5GiB set 1 esp on;
  parted -s --align optimal "$1" -- mkpart 'SWAP'   5GiB  20GiB;
  parted -s --align optimal "$1" -- mkpart 'CACHE' 20GiB  40GiB;
  parted -s --align optimal "$1" -- mkpart 'ROOT'  40GiB '100%';
  parted -s --align optimal "$1" -- print;
  mkfs.vfat "${1}p1";
  mkswap "${1}p2";
}
```

# ZFS

Then ZFS pool:
```sh
zpool create \
    -O canmount=off \
    -O mountpoint=legacy \
    -O acltype=posixacl \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O atime=off \
    -O xattr=sa \
    rpool /dev/nvme0n1p4
```
And some basic ZFS volumes:
```
zfs create -o canmount=off -o quota=10G -o reservation=10G rpool/reserve;
zfs create -o canmount=on  -o quota=10G -o reservation=10G rpool/home;
zfs create -o canmount=on  -o quota=10G -o reservation=10G rpool/root;
zfs create -o canmount=on  -o quota=40G -o reservation=40G rpool/nix;
```

# Installation

Mount volumes:
```sh
swapon /dev/nvme0n1p2
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```
After configuring NixOS run installation process:
```
nix-channel --add https://nixos.org/channels/nixos-23.05 nixos-23.05
nix-channel --update
nixos-install
```
Unmount and reboot:
```
umount /mnt/boot
umount /mnt
reboot
```
