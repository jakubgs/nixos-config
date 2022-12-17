# Description

Describes installtion process on NanoPC-T4 `sachiel` host.

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
