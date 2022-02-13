# Description

Describes installtion process on EX42 Hetzner host.

# Partitioning

We need a GRUB boot partition, swap, and ZFS volume:
```sh
export DISK=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0
parted -s --align optimal "$DISK" -- mklabel gpt
parted -s --align optimal "$DISK" -- mkpart 'BIOS' 1MiB 2MiB set 1 bios_grub on
parted -s --align optimal "$DISK" -- mkpart 'EFI'  2MiB 1GiB set 2 esp on
parted -s --align optimal "$DISK" -- mkpart 'SWAP' 1GiB 5GiB set 2 esp on
parted -s --align optimal "$DISK" -- mkpart 'ZFS'  5GiB '100%'
parted -s --align optimal "$DISK" -- print
```

# Filesystems

First GRUB partition and SWAP:
```sh
mkfs.ext4 $DISK-part2
swapon $DISK-part3
```
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
  rpool \
  $DISK-part4
```
And some basic ZFS volumes:
```
sudo zfs create -o canmount=off -o quota=5G -o reservation=5G  rpool/reserve
sudo zfs create -o canmount=on -o quota=20G -o reservation=20G rpool/root
sudo zfs create -o canmount=on -o quota=20G -o reservation=20G rpool/nix
sudo zfs create -o canmount=on -o quota=20G -o reservation=20G rpool/home
```

# Installation

```sh
zpool import -f rpool
mount.zfs rpool/root /mnt
mkdir -p /mnt/nix /mnt/home /mnt/boot
mount.zfs rpool/nix /mnt/nix
mount.zfs rpool/home /mnt/home
mount $DISK-part2 /mnt/boot
```
After configuring NixOS run installation process:
```
nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
nix-channel --update
nixos-install
```
Unmount and reboot:
```
umount /mnt/nix
umount /mnt/home
umount /mnt/boot
umount /mnt
zpool export rpool
reboot
```

# Links

* https://nixos.wiki/wiki/ZFS
* https://nixos.wiki/wiki/Bootloader
* https://orovecchia.com/posts/hetzner-cloud-with-nixos/
