#!/usr/bin/env bash

set -euo pipefail

function add_missing_pkg() {
    local command=${1} package=${2}
    command -v ${command} 2>&1 >/dev/null && return
    nix profile add ${package}
}

# Necessary for deployment of secrets to work.
[[ -z "${ED25519_KEY:-}" ]] && { echo "No ED25519_KEY env var provided."; exit 1; }

export NIX_CONFIG='experimental-features = nix-command flakes'
export FLAKE='github:jakubgs/nixos-config#gaghiel'

set -x

# This is expected to run from an Armbian SD card image.
if command -v apt 2>&1 >/dev/null; then
    apt install --yes xz-utils git tmux linux-headers-vendor-rk35xx linux-headers-edge-rockchip-rk3588
    apt install --yes zfs-dkms zfsutils
fi

# Install Nix if missing.
if [[ ! -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fi

# Source Nix if not available.
if ! command -v nix 2>&1 >/dev/null; then
    set +x
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    set -x
fi

# Install Disko
add_missing_pkg disko 'github:nix-community/disko/1.11.0#disko-install'

# Format filesystem
disko --mode destroy,format,mount --flake "${FLAKE}" --yes-wipe-all-disks

# Deploy host keys
mkdir -p /mnt/etc/ssh
set +x
echo "${ED25519_KEY}" > "/mnt/etc/ssh/ssh_host_ed25519_key"
chmod 600 "/mnt/etc/ssh/ssh_host_ed25519_key"
echo "${ED25519_KEY}" | ssh-keygen -y -f /dev/stdin > "/mnt/etc/ssh/ssh_host_ed25519_key.pub"
set -x

# Install EDK2 EFI Bootloader
if [[ ! -f rock-5c_UEFI_Release_v1.1.img ]]; then
    wget https://github.com/kwankiu/edk2-rk3588/releases/download/v1.1/rock-5c_UEFI_Release_v1.1.img
fi
EMMC_DEV='/dev/disk/by-id/mmc-DA6064_0x16f81d00'
dd if=rock-5c_UEFI_Release_v1.1.img of="${EMMC_DEV}" bs=512 skip=$((0x800)) seek=$((0x4000)) conv=notrunc
sgdisk -p "${EMMC_DEV}"
hexdump -C -n 4 -s $((0x800 * 512)) "${EMMC_DEV}"

# Install NixOS installation tools
add_missing_pkg nixos-install 'nixpkgs#nixos-install-tools'
# Hack-fix for missing 'mount' during activation.
ln -sf /nix/var/nix/profiles/system/sw/bin /mnt/sbin

# Install NixOS
nixos-install --flake "${FLAKE}"
