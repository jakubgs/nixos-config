# Description

Manual partitioning and installation,

## Partitioning

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

## ZFS Pool

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

## Installation

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
