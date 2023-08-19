# Boot
```
# Generated file, all changes will be lost on nixos-rebuild!

# Change this to e.g. nixos-42 to temporarily boot to an older configuration.
DEFAULT nixos-default

MENU TITLE ------------------------------------------------------------
TIMEOUT 50

LABEL nixos-default
  MENU LABEL NixOS - Default
  LINUX ../nixos/szyy7b8mhh1irw38kyqm8hbllsc0ghby-linux-6.1.23-Image
  INITRD ../nixos/9216lf5r8m8md7qyrzwgf7jzh2s1l1ik-initrd-linux-6.1.23-initrd
  APPEND init=/nix/store/5zgq9vs980pckgvwiplf4flwhs7iknj1-nixos-system-sachiel-22.11.20230413.2b1bba7/init console=ttyS2,1500000 loglevel=4
  FDTDIR ../nixos/szyy7b8mhh1irw38kyqm8hbllsc0ghby-linux-6.1.23-dtbs
```

# Disks
```
 > ls -l /dev/disk/by-id 
total 0
lrwxrwxrwx 1 root root 13 May 21  2022 mmc-AJTD4R_0x2a92dcf1 -> ../../mmcblk2
lrwxrwxrwx 1 root root 15 Jan 18  2013 mmc-AJTD4R_0x2a92dcf1-part1 -> ../../mmcblk2p1
lrwxrwxrwx 1 root root 13 May 21  2022 nvme-eui.0025385691b60a37 -> ../../nvme0n1
lrwxrwxrwx 1 root root 15 May 21  2022 nvme-eui.0025385691b60a37-part1 -> ../../nvme0n1p1
lrwxrwxrwx 1 root root 15 May 21  2022 nvme-eui.0025385691b60a37-part9 -> ../../nvme0n1p9
lrwxrwxrwx 1 root root 13 May 21  2022 nvme-Samsung_SSD_970_EVO_Plus_250GB_S4EUNF0M663546L -> ../../nvme0n1
lrwxrwxrwx 1 root root 15 May 21  2022 nvme-Samsung_SSD_970_EVO_Plus_250GB_S4EUNF0M663546L-part1 -> ../../nvme0n1p1
lrwxrwxrwx 1 root root 15 May 21  2022 nvme-Samsung_SSD_970_EVO_Plus_250GB_S4EUNF0M663546L-part9 -> ../../nvme0n1p9
```
```
 > sudo lsblk --fs
NAME         FSTYPE     FSVER LABEL    UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
mmcblk2                                                                                    
└─mmcblk2p1  ext4       1.0   NIXOS_SD 4adaf361-6b1e-47d1-95e3-c24d53f3937c   12.8G     5% /boot
mmcblk2boot0                                                                               
mmcblk2boot1                                                                               
zd0          swap       1              09a75307-8dda-4e21-9a91-709d0dc3338a                [SWAP]
nvme0n1                                                                                    
├─nvme0n1p1  zfs_member 5000  rpool    10911812279686855190                                
└─nvme0n1p9
```
```
 > sudo fdisk -l
Disk /dev/mmcblk2: 14.56 GiB, 15634268160 bytes, 30535680 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 3DF03D1D-E51E-B04E-B2B6-E454EA5A5F54

Device         Start      End  Sectors  Size Type
/dev/mmcblk2p1 32768 30533631 30500864 14.5G Linux filesystem


Disk /dev/mmcblk2boot0: 4 MiB, 4194304 bytes, 8192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mmcblk2boot1: 4 MiB, 4194304 bytes, 8192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/nvme0n1: 232.89 GiB, 250059350016 bytes, 488397168 sectors
Disk model: Samsung SSD 970 EVO Plus 250GB          
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 7BF4B90B-D5E8-2A4B-9D05-08A6D33AEF3E

Device             Start       End   Sectors   Size Type
/dev/nvme0n1p1      2048 488380415 488378368 232.9G Solaris /usr & Apple ZFS
/dev/nvme0n1p9 488380416 488396799     16384     8M Solaris reserved 1


Disk /dev/zd0: 4 GiB, 4294967296 bytes, 8388608 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```
# Speed
```
 > sudo hdparm -tT /dev/nvme0n1

/dev/nvme0n1:
 Timing cached reads:   2706 MB in  2.00 seconds = 1353.29 MB/sec
 Timing buffered disk reads: 1590 MB in  3.00 seconds = 529.87 MB/sec

 > sudo hdparm -tT /dev/nvme0n1

/dev/nvme0n1:
 Timing cached reads:   2620 MB in  2.00 seconds = 1310.41 MB/sec
 Timing buffered disk reads: 1646 MB in  3.00 seconds = 548.38 MB/sec
```
# Speed NEW
```

```
