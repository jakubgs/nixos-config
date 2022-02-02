# Description

Describes installtion process on EX42 Hetzner host.

# Partitioning

It's necessary to use GPT instead of `msdos` partitions to handle the 4TB drives.

Some env variables to avoid boilerplate:
```
export DISK1=/dev/disk/by-id/ata-TOSHIBA_MG04ACA400EY_586IK061F7GB
export DISK2=/dev/disk/by-id/ata-TOSHIBA_MG04ACA400EY_586IK063F7GB
```

## GPT

This function is used for formatting drives
```sh
format() {
  parted -s --align optimal "$1" -- mklabel gpt
  parted -s --align optimal "$1" -- mkpart 'BIOS' 1MB 2MB set 1 bios_grub on
  parted -s --align optimal "$1" -- mkpart 'EFI' 2MB 1GiB set 2 esp on
  parted -s --align optimal "$1" -- mkpart 'SWAP' 1GiB 33GiB set 2 esp on
  parted -s --align optimal "$1" -- mkpart 'ZFS' 33GiB '100%'
  parted -s --align optimal "$1" -- print
}
```
Result:
```
 > sudo parted -l
Model: ATA TOSHIBA MG04ACA4 (scsi)
Disk /dev/sda: 4001GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system     Name  Flags
 1      1049kB  2097kB  1049kB                  BIOS  bios_grub
 2      2097kB  1074MB  1072MB  ext4            EFI   msftdata
 3      1074MB  35.4GB  34.4GB  linux-swap(v1)  SWAP
 4      35.4GB  4001GB  3965GB                  ZFS


Model: ATA TOSHIBA MG04ACA4 (scsi)
Disk /dev/sdb: 4001GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system     Name  Flags
 1      1049kB  2097kB  1049kB                  BIOS  bios_grub
 2      2097kB  1074MB  1072MB  ext4            EFI   msftdata
 3      1074MB  35.4GB  34.4GB  linux-swap(v1)  SWAP
 4      35.4GB  4001GB  3965GB                  ZFS
```

## BOOT

The first partition is a [BIOS boot partition](https://en.wikipedia.org/wiki/BIOS_boot_partition) and the second is for Grub.
```
mkfs.ext4 $DISK1-part2
mkfs.ext4 $DISK2-part2
```

## ZFS

The ZFS pool uses ZSTD compression and some other optimizations:
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
  rpool raidz \
  $DISK1-part4 \
  $DISK2-part4

sudo zfs create -o canmount=on -o quota=50G -o reservation=50G rpool/root
sudo zfs create -o canmount=on -o quota=50G -o reservation=50G rpool/nix
sudo zfs create -o canmount=on -o quota=50G -o reservation=50G rpool/home
```

## SWAP

Gotta have some:
```
mkswap $DISK1-part3
mkswap $DISK2-part3
swapon $DISK1-part3
swapon $DISK2-part3
```

# Installation

Get all the volumes mounted:
```
mount.zfs rpool/root /mnt
mount.zfs rpool/nix /mnt/nix
mount.zfs rpool/home /mnt/home
mount $DISK1-part2 /mnt/boot1
mount $DISK2-part2 /mnt/boot2
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
umount /mnt/boot1
umount /mnt/boot2
umount /mnt
zpool export rpool
reboot
```

# Links

* https://mazzo.li/posts/hetzner-zfs.html
* https://nixos.wiki/wiki/ZFS
* https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online
* https://nixos.org/manual/nixos/stable/index.html#sec-installation
* https://docs.hetzner.com/robot/dedicated-server/operating-systems/uefi/
* https://docs.hetzner.com/robot/dedicated-server/operating-systems/efi-system-partition/
* https://github.com/nix-community/nixos-install-scripts/blob/master/hosters/hetzner-dedicated/zfs-uefi-nvme-nixos.sh
* https://discourse.nixos.org/t/configure-grub-on-efi-system/2926/
