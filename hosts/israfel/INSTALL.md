# Description

Describes installation process on Rock 5B `israfel` host.

# Install Image

I used an Armbian 23.8 Bookworm image: <https://www.armbian.com/rock-5b/>

:warning: The stock [NixOS `aarch64` SD image](https://hydra.nixos.org/job/nixos/release-24.11/nixos.sd_image.aarch64-linux) does not work currently.

Alternatively a [NixOS `aarch64` ISO image](https://hydra.nixos.org/job/nixos/release-24.11/nixos.iso_minimal.aarch64-linux) can be used on a USB pendrive.

Install Nix package manager using [the usual methods](https://nixos.wiki/wiki/Nix_Installation_Guide) and then install `nixos-install-tools`:
```sh
apt install --yes xz-utils git tmux linux-headers-vendor-rk35xx linux-headers-edge-rockchip-rk3588
apt install --yes zfs-dkms zfsutils
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix-env -iA nixos-install-tools
```

# Installation

Install [Disko partitioning tool](https://github.com/nix-community/disko)
```sh
nix --extra-experimental-features 'nix-command flakes' profile install 'github:nix-community/disko/latest'
```
Partition the filesystem:
```sh
disko --mode destroy,format,mount --flake 'github:jakubgs/nixos-config#israfel' --yes-wipe-all-disks
```
Perform the installation:
```sh
nixos-install --flake 'github:jakubgs/nixos-config#israfel'
```

See [MANUAL.md](./MANUAL.md) for step-by-step instructions.
