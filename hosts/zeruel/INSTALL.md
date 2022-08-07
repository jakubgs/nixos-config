# Description

Describes installtion process on EX42 Hetzner host.

# Booting

To boot into a NixOS installation image we have to build a `kexec` image using these instructions:
https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online

# Partitioning

Systemd disks:
```sh
export DISK1=/dev/disk/by-id/ata-Micron_1100_MTFDDAK512TBN_172618D7FA26
export DISK2=/dev/disk/by-id/ata-Micron_1100_MTFDDAK512TBN_172618D7FAB2
```
We need a GRUB boot partition, swap, and ZFS volume:
```sh
format() {
  parted -s --align optimal "$1" -- mklabel gpt
  parted -s --align optimal "$1" -- mkpart 'BIOS' 1MiB 2MiB set 1 bios_grub on
  parted -s --align optimal "$1" -- mkpart 'EFI'  2MiB 1GiB set 2 esp on
  parted -s --align optimal "$1" -- mkpart 'SWAP' 1GiB 33GiB set 2 esp on
  parted -s --align optimal "$1" -- mkpart 'ZFS'  33GiB '100%'
  parted -s --align optimal "$1" -- print
}
```
Result:
```
 > sudo parted -l
Model: ATA Micron_1100_MTFD (scsi)
Disk /dev/sda: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2097kB  1049kB               BIOS  bios_grub
 2      2097kB  1074MB  1072MB               EFI   boot, esp
 3      1074MB  35.4GB  34.4GB               SWAP
 4      35.4GB  512GB   477GB                ZFS

Model: ATA Micron_1100_MTFD (scsi)
Disk /dev/sdb: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2097kB  1049kB               BIOS  bios_grub
 2      2097kB  1074MB  1072MB               EFI   boot, esp
 3      1074MB  35.4GB  34.4GB               SWAP
 4      35.4GB  512GB   477GB                ZFS
```

## BOOT

```sh
mkfs.ext4 $DISK1-part2
mkfs.ext4 $DISK2-part2
```

## SWAP

```
mkswap $DISK1-part3
mkswap $DISK2-part3
swapon $DISK1-part3
swapon $DISK2-part3
```

## ZFS

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
  rpool mirror \
  $DISK1-part4 \
  $DISK2-part4
```
And some basic ZFS volumes:
```
sudo zfs create -o canmount=off -o quota=10G -o reservation=10G rpool/reserve
sudo zfs create -o canmount=on  -o quota=50G -o reservation=50G rpool/root
sudo zfs create -o canmount=on  -o quota=50G -o reservation=50G rpool/nix
sudo zfs create -o canmount=on  -o quota=20G -o reservation=20G rpool/home
sudo zfs create -o canmount=on  -o encryption=on -o keyformat=passphrase -o keylocation=prompt rpool/secret
```

# Installation

```sh
zpool import -f rpool
mount.zfs rpool/root /mnt
mkdir -p /mnt/nix /mnt/home /mnt/boot1 /mnt/boot2
mount.zfs rpool/nix /mnt/nix
mount.zfs rpool/home /mnt/home
mount $DISK1-part2 /mnt/boot1
mount $DISK2-part2 /mnt/boot2
```
After configuring NixOS run installation process:
```
nix-channel --add https://nixos.org/channels/nixos-22.05 nixos-22.05
nix-channel --update
nixos-install
```
Unmount and reboot:
```
umount /mnt/boot1
umount /mnt/boot2
umount /mnt/home
umount /mnt/nix
umount /mnt
zpool export rpool
reboot
```

# Links

* https://nixos.wiki/wiki/ZFS
* https://nixos.wiki/wiki/Bootloader
* https://orovecchia.com/posts/hetzner-cloud-with-nixos/
* https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online
