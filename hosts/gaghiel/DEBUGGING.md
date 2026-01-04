# Description

This documents issues with booting using EDK2 fork from https://github.com/kwankiu/edk2-rk3588 while also creating partition layout with Disko.

# What Works

Just writing the [`rock-5c_UEFI_Release_v1.1.img`](https://github.com/kwankiu/edk2-rk3588/releases/download/v1.1/rock-5c_UEFI_Release_v1.1.img) directly to the eMMC:
```bash
dd if=rock-5c_UEFI_Release_v1.1.img of=/dev/disk/by-id/mmc-DA6064_0x16f81d00
```
This creates this partition layout on the eMMC:
```
 > fdisk -l rock-5c_UEFI_Release_v1.1.img
GPT PMBR size mismatch (32767 != 13506) will be corrected by write.
Disk rock-5c_UEFI_Release_v1.1.img: 6.6 MiB, 6915584 bytes, 13507 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device                         Boot Start   End Sectors  Size Id Type
rock-5c_UEFI_Release_v1.1.img1          1 13506   13506  6.6M ee GPT
```
And loads EDK2 UEFI bootloader fine without issues and shows this in logs:
```
U-Boot SPL board init
U-Boot SPL 2017.09-g5f53abfa1e-221223 #zzz (Dec 26 2022 - 09:10:09)
unknown raw ID 0 0 0
unrecognized JEDEC id bytes: 00, 00, 00
Trying to boot from MMC2
MMC: no card present
mmc_init: -123, time 0
spl: mmc init failed with error: -123
Trying to boot from MMC1
No misc partition
Trying fit image at 0x800 sector
## Verified-boot: 0
## Checking atf-1 0x00040000 ... sha256(3c38e69286...) + OK
## Checking edk2 0x00200000 ... sha256(403d74a45a...) + OK
## Checking atf-2 0x000f0000 ... sha256(e3b0c44298...) + OK
## Checking atf-3 0xff100000 ... sha256(f6c21c7eec...) + OK
## Checking optee 0x08400000 ... sha256(66e4b7a4cd...) + OK
## Checking nvdata 0x007c0000 ... OK
Jumping to U-Boot(0x00200000) via ARM Trusted Firmware(0x00040000)
Total: 176.446 ms

NOTICE:  BL31: v2.12.0(release):d5c68fd
NOTICE:  BL31: Built : 15:57:30, Apr 18 2025
UEFI firmware (version v1.1 built at 15:58:46 on Apr 18 2025)
```

# What Does Not Work

Using this [`disko-config.nix`](https://github.com/jakubgs/nixos-config/blob/master/hosts/gaghiel/disko-config.nix) to create partition layout:
```
 > fdisk -l /dev/disk/by-id/mmc-DA6064_0x16f81d00
Disk /dev/disk/by-id/mmc-DA6064_0x16f81d00: 58.24 GiB, 62537072640 bytes, 122142720 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 545FB880-3F71-494D-B187-B90F8844FE2A

Device                                         Start       End   Sectors  Size Type
/dev/disk/by-id/mmc-DA6064_0x16f81d00-part1     2048     18431     16384    8M Linux filesystem
/dev/disk/by-id/mmc-DA6064_0x16f81d00-part2    18432   2115583   2097152    1G EFI System
/dev/disk/by-id/mmc-DA6064_0x16f81d00-part3  2115584  10504191   8388608    4G Linux swap
/dev/disk/by-id/mmc-DA6064_0x16f81d00-part4 10504192 122140671 111636480 53.2G Linux filesystem
```
Then writing the EDK2 UEFI release with `dd` wth an offset:
```bash
dd if=rock-5c_UEFI_Release_v1.1.img of=/dev/disk/by-id/mmc-DA6064_0x16f81d00 bs=512 skip=64 seek=64 conv=notrunc
```
And then that fails to boot with:
```
U-Boot SPL board init
U-Boot SPL 2017.09-g5f53abfa1e-221223 #zzz (Dec 26 2022 - 09:10:09)
unknown raw ID 0 0 0
unrecognized JEDEC id bytes: 00, 00, 00
Trying to boot from MMC2
MMC: no card present
mmc_init: -123, time 0
spl: mmc init failed with error: -123
Trying to boot from MMC1
No misc partition
spl: partition error
Trying fit image at 0x4000 sector
Not fit magic
Trying fit image at 0x5000 sector
Not fit magic
SPL: failed to boot from all boot devices
### ERROR ### Please RESET the board ###
```

# Solution

Move `uboot` partition for EDK2 forther to 16M in Disko config. Then write the UEFI image with an adjusted offset:
```
dd if=rock-5c_UEFI_Release_v1.1.img \
   of=/dev/disk/by-id/mmc-DA6064_0x16f81d00 \
   bs=512 skip=$((0x800)) seek=$((0x4000)) conv=notrunc
```
