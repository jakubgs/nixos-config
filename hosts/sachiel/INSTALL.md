# Description

Describes installtion process on NanoPC-T4 `sachiel` host.

# Install Image

You can build a custom install image using the [`sd-image.nix`](./sd-image.nix):
```sh
nixos-generate -f sd-aarch64-installer --system aarch64-linux -c sd-image.nix -I nixpkgs=$HOME/nixpkgs
```
For more details see [this article](https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/).

# External Drives

Env variable to avoid boilerplate:
```
export DISK1=/dev/disk/by-id/ata-Patriot_P210_2048GB_P210EDCB22103100065
export DISK2=/dev/disk/by-id/ata-Patriot_P210_2048GB_P210EDCB22103100079
```

## ZFS

The ZFS pool uses ZSTD compression and some other optimizations:
```sh
sudo zpool create \
  -O encryption=on \
  -O keyformat=passphrase \
  -O keylocation=prompt \
  -O canmount=off \
  -O mountpoint=legacy \
  -O acltype=posixacl \
  -O compression=zstd \
  -O dnodesize=auto \
  -O normalization=formD \
  -O atime=off \
  -O xattr=sa \
  USB-HDD mirror \
  $DISK1 $DISK2
```
```
sudo zfs create -o canmount=on -o quota=100G -o reservation=100G USB-HDD/music
sudo zfs create -o canmount=on -o quota=100G -o reservation=100G USB-HDD/photos
sudo zfs create -o canmount=on -o quota=140G -o reservation=140G USB-HDD/data
sudo zfs create -o canmount=on -o quota=20G  -o reservation=10G  USB-HDD/mobile
sudo zfs create -o canmount=on -o quota=20G  -o reservation=10G  USB-HDD/git
sudo zfs create -o canmount=on -o quota=1.4T -o reservation=1.4T USB-HDD/torrent
```

# Kernel

A [custom kernel](./KERNEL.md) is built due to [known issues with PCI-E timouts](./KNOWN_ISSUES.md).

The [kernel config](./kernel.config) is used both for the system and the recovery/install [SD card image](./sd-image.nix).
