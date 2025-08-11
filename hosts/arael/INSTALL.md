# Description

Describes installation process on Rock 5B `israfel` host.

# Bootloader

The best available bootloader is [EDK2 UEFI firmware for Rockchip RK3588 platforms](https://github.com/edk2-porting/edk2-rk3588). The [`0.9.1`](https://github.com/edk2-porting/edk2-rk3588/releases/tag/v0.9.1) release is confirmed working.

In order to flash this bootloader we'll need to download the bootloader image:

* [`nanopi-r6c_UEFI_Release_v0.9.1.img`](https://github.com/edk2-porting/edk2-rk3588/releases/download/v0.9.1/nanopi-r6c_UEFI_Release_v0.9.1.img)

And write it to the eMMC device:
```
NanoPi-R6C% sudo dd if=nanopi-r6c_UEFI_Release_v0.9.1.img of=/dev/mmcblk2 bs=1M
6+1 records in   
6+1 records out
7012864 bytes (7.0 MB, 6.7 MiB) copied, 0.0319496 s, 219 MB/s
```
Now the device has a graphical bootloader available when pressing `Escape` at boot time:

![Bootloader Menu](./bootloader.png)

# Install Image

You can use a stock `aarch64` installer ISO image:
https://hydra.nixos.org/job/nixos/release-23.05/nixos.iso_minimal.aarch64-linux

We can't use SD card image since it doesn't support UEFI boot.

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
zfs create -o canmount=on  -o encryption=on -o keyformat=passphrase -o keylocation=prompt rpool/secret;
zfs create -o canmount=on  -o quota=1.2T -o reservation=1.2T rpool/secret/torrent;
zfs create -o canmount=on  -o quota=130G -o reservation=130G rpool/secret/music;
zfs create -o canmount=on  -o quota=100G -o reservation=100G rpool/secret/photos;
zfs create -o canmount=on  -o quota=50G  -o reservation=50G  rpool/secret/data;
zfs create -o canmount=on  -o quota=20G  -o reservation=10G  rpool/secret/git;
zfs create -o canmount=on  -o quota=20G  -o reservation=10G  rpool/secret/mobile;
```

# Installation

Mount volumes:
```sh
swapon /dev/nvme0n1p2;
mount.zfs rpool/root /mnt;
mkdir /mnt/nix /mnt/boot /mnt/home /mnt/etc;
mount.zfs rpool/home /mnt/home;
mount.zfs rpool/nix /mnt/nix;
mount /dev/nvme0n1p1 /mnt/boot;
```
After configuring NixOS run installation process:
```
nix-channel --update
nixos-install
```
Unmount and reboot:
```
umount /mnt/boot
umount /mnt
reboot
```
