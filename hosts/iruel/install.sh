#!/usr/bin/env bash

# This is expected to run from an Armbian SD card image.
if ! command -v apt 2>&1 >/dev/null; then
    apt install --yes xz-utils git tmux linux-headers-vendor-rk35xx linux-headers-edge-rockchip-rk3588
    apt install --yes zfs-dkms zfsutils

    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

nix --extra-experimental-features 'nix-command flakes' profile install 'github:nix-community/disko/latest#disko-install'

disko --mode destroy,format,mount --flake 'github:jakubgs/nixos-config#iruel' --yes-wipe-all-disks

nixos-install --flake 'github:jakubgs/nixos-config#iruel'
