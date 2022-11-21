# Description

Describes installtion process on Thinkpad T480s `lilim` host.

# Installation

## Partitioning

It's necessary to use GPT instead of `msdos` partitions to handle more than 2TB.

Env variable to avoid boilerplate:
```
export DISK=/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S6Z2NJ0TA04678D
```
Function for formatting
```sh
format() {
  parted --script -s -a optimal "$1" \
    mklabel gpt \
    mkpart BIOS 1MB   2MB   set 1 bios_grub on \
    mkpart EFI  2MB   3GiB  set 1 esp on \
    mkpart SWAP 3GiB  19GiB \
    mkpart ZFS  19GiB 100% \
    print
}
format $DISK
```
Result:
```
Model: Samsung SSD 990 PRO 2TB (nvme)
Disk /dev/nvme0n1: 2000GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2097kB  1049kB               BIOS  boot, esp
 2      2097kB  3221MB  3219MB               EFI
 3      3221MB  20.4GB  17.2GB               SWAP
 4      20.4GB  2000GB  1980GB               ZFS
```

## BOOT

```
mkfs.vfat $DISK-part2
```

## SWAP

Gotta have some:
```
mkswap $DISK-part3
swapon $DISK-part3
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
  rpool \
  $DISK-part4
```
```
zfs create -o canmount=on -o encryption=on -o keyformat=passphrase -o keylocation=prompt rpool/secret
zfs create -o canmount=on -o quota=30G  -o reservation=30G  rpool/root
zfs create -o canmount=on -o quota=100G -o reservation=100G rpool/nix
zfs create -o canmount=on -o quota=100G -o reservation=100G rpool/docker
zfs create -o canmount=on -o quota=100G -o reservation=100G rpool/music
zfs create -o canmount=on -o quota=100G -o reservation=100G rpool/mobile
zfs create -o canmount=on -o quota=200G -o reservation=200G rpool/secret/home
zfs create -o canmount=on -o quota=150G -o reservation=150G rpool/secret/data
zfs create -o canmount=on -o quota=10G  -o reservation=10G  rpool/secret/git
```

# Installation

get all the volumes mounted:
```
mount.zfs rpool/root /mnt
mkdir -p /mnt/boot /mnt/nix /mnt/home /mnt/mnt/data /mnt/mnt/music /mnt/mnt/git /mnt/var/lib/docker
mount.zfs rpool/nix /mnt/nix
mount.zfs rpool/docker /mnt/var/lib/docker
mount.zfs rpool/secret/home /mnt/home
mount.zfs rpool/secret/data /mnt/mnt/data
mount.zfs rpool/secret/git /mnt/mnt/git
mount $DISK-part2 /mnt/boot
```
After configuring NixOS run installation process:
```
nixos-install --flake /mnt/etc/nixos\#lilim
```
Unmount and reboot:
```
umount /mnt/nix /mnt/home /mnt/boot /mnt/mnt/data /mnt/mnt/git /mnt/var/lib/docker /mnt
zpool export rpool
reboot
```
