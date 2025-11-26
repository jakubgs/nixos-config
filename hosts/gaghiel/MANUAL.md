# Description

Manual partitioning and installation,

# Partitioning

To partition the NVMe the following layout is used:
```sh
format() {
  parted -s --align optimal "$1" -- mklabel gpt;
  parted -s --align optimal "$1" -- mkpart 'uboot'  2048s 18431s;
  parted -s --align optimal "$1" -- mkpart 'EFI'   18431s   5GiB set 1 esp on;
  parted -s --align optimal "$1" -- mkpart 'SWAP'    5GiB   8GiB;
  parted -s --align optimal "$1" -- mkpart 'ROOT'    8GiB '100%';
  parted -s --align optimal "$1" -- print;
  mkfs.vfat "${1}p1";
  mkswap "${1}p2";
}
```
