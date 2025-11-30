# Description

Describes installtion process on NanoPC-T4 `sachiel` host.

# Install Image

You can build a custom install image using the [`sd-image.nix`](./sd-image.nix):
```sh
nixos-generate -f sd-aarch64-installer --system aarch64-linux -c sd-image.nix -I nixpkgs=$HOME/nixpkgs
```
For more details see [this article](https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/).

# System

## Partitioning

To partition the NVMe the following layout is used:
```sh
format() {
  wipefs -a "$1";
  parted -s --align optimal "$1" -- mklabel msdos;
  parted -s --align optimal "$1" -- mkpart primary    0  30GiB;
  parted -s --align optimal "$1" -- mkpart primary 30GiB '100%';
  parted -s --align optimal "$1" -- print;
  mkswap "${1}p1";
}
```

# ZFS

ZFS pool creation:
```
zpool create \
    -O canmount=off \
    -O mountpoint=legacy \
    -O acltype=posixacl \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O atime=off \
    -O xattr=sa \
    rpool /dev/nvme0n1p2
```
And some basic ZFS volumes:
```
zfs create -o canmount=off -o quota=10G -o reservation=10G rpool/reserve;
zfs create -o canmount=on  -o quota=50G -o reservation=10G rpool/home;
zfs create -o canmount=on  -o quota=20G -o reservation=10G rpool/root;
zfs create -o canmount=on  -o quota=50G -o reservation=40G rpool/nix;
```

# ZFS On USB Enclosure

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
  /dev/sda
```
```
sudo zfs create -o canmount=on -o quota=100G -o reservation=150G USB-DATA/music
sudo zfs create -o canmount=on -o quota=200G -o reservation=200G USB-DATA/photos
sudo zfs create -o canmount=on -o quota=50G  -o reservation=50G  USB-DATA/data
sudo zfs create -o canmount=on -o quota=20G  -o reservation=30G  USB-DATA/mobile
sudo zfs create -o canmount=on -o quota=20G  -o reservation=10G  USB-DATA/git
```

# Boot

To boot extra modules are necessary in the initial ramdisk due to [known issues with PCI-E timouts](./KNOWN_ISSUES.md).

See [`configuration.nix`](./configuration.nix) for `boot.initrd.availableKernelModules` setting.

It is also possible to build a custom [kernel config](./kernel.config) for both for the system and the recovery/install [SD card image](./sd-image.nix), but it also can have trouble booting.
