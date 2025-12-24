#!/usr/bin/env bash

set -exuo pipefail

# This is expected to run from an Armbian SD card image.
if command -v apt 2>&1 >/dev/null; then
    apt install --yes xz-utils git tmux linux-headers-vendor-rk35xx linux-headers-edge-rockchip-rk3588
    apt install --yes zfs-dkms zfsutils
fi

# Install Nix if missing.
if [[ ! -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fi

function add_missing_pkg() {
    local command=${1} package=${2}
    command -v ${command} 2>&1 >/dev/null && return
    nix --extra-experimental-features 'nix-command flakes' \
        profile add ${package}
}

# Source Nix if not available.
if ! command -v nix 2>&1 >/dev/null; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Install Disko
add_missing_pkg disko 'github:nix-community/disko/latest#disko-install'

# Format filesystem
disko --mode destroy,format,mount --flake 'github:jakubgs/nixos-config#gaghiel' --yes-wipe-all-disks

# Instsall EDK2 EFI Bootloader
wget https://github.com/kwankiu/edk2-rk3588/releases/download/v1.1/rock-5c_UEFI_Release_v1.1.img
dd if=rock-5c_UEFI_Release_v1.1.img of=/dev/disk/by-id/mmc-DA6064_0x16f81d00-part1 bs=512 skip=64 conv=notrunc

# Install NixOS installation tools
add_missing_pkg nixos-install 'nixpkgs#nixos-install-tools'

# Install NixOS
nixos-install --flake 'github:jakubgs/nixos-config#gaghiel'

echo; read -r -n1 -p "Reboot? [y/n] " REPLY; echo
if [[ "${REPLY}" =~ [Yy] ]]; then
    disko --mode umount --flake 'github:jakubgs/nixos-config#gaghiel'
    reboot
fi
