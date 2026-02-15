#!/usr/bin/env bash

set -euo pipefail

function setup_zfs_on_armbian() {
    if command -v apt 2>&1 >/dev/null; then
        apt install --yes xz-utils git tmux linux-headers-vendor-rk35xx linux-headers-edge-rockchip-rk3588
        apt install --yes zfs-dkms zfsutils
    fi
}

function setup_and_source_nix() {
    # Source Nix if not available.
    if ! command -v nix 2>&1 >/dev/null; then
        if [[ ! -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
            sh <(curl -L https://nixos.org/nix/install) --daemon --yes
        fi
        set +x # Sourcing Nix is way too verbose.
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        set -x
    fi
}

function add_missing_pkg() {
    local command=${1} package=${2}
    command -v ${command} 2>&1 >/dev/null && return
    nix profile add ${package}
}

function deploy_host_private_keys() {
    mkdir -p /mnt/etc/ssh
    set +x # Avoid printing secrets.
    echo "${ED25519_KEY}" > "/mnt/etc/ssh/ssh_host_ed25519_key"
    echo "${ED25519_KEY}" | ssh-keygen -y -f /dev/stdin > "/mnt/etc/ssh/ssh_host_ed25519_key.pub"
    chmod 600 "/mnt/etc/ssh/ssh_host_ed25519_key"
    set -x
}

function install_uefi_bootloader() {
    EDK2_VER='v1.1'
    EDK2_IMG="nanopi-r6c_UEFI_Release_${EDK2_VER}.img"
    EDK2_REPO='https://github.com/edk2-porting/edk2-rk3588'
    if [[ ! -f "${EDK2_IMG}" ]]; then
        wget "${EDK2_REPO}/releases/download/${EDK2_VER}/${EDK2_IMG}"
    fi
    #EMMC_DEV='/dev/disk/by-id/mmc-TODO' # A3A551 3F86D8D0
    EMMC_DEV='/dev/mmcblk2'
    if [[ ! -v "${EMMC_DEV}" ]]; then
        echo "No eMMC device found: ${EMMC_DEV}"
        exit 1
    fi
    dd if="${EDK2_IMG}" of="${EMMC_DEV}" bs=512 skip=$((0x800)) seek=$((0x4000)) conv=notrunc
}

# Necessary for deployment of secrets to work.
[[ -z "${ED25519_KEY:-}" ]] && { echo "No ED25519_KEY env var provided."; exit 1; }

# Show almost all commands executed.
set -x

export HOSTNAME='arael'
export FLAKE="github:jakubgs/nixos-config#${HOSTNAME}"
export NIX_CONFIG='experimental-features = nix-command flakes'

# In case we are running on Armbian SD card image.
setup_zfs_on_armbian

# Install Nix if missing and source the profile.
setup_and_source_nix

# Install Disko
add_missing_pkg disko 'github:nix-community/disko/v1.13.0#disko-install'

# Format filesystem
disko --mode destroy,format,mount --flake "${FLAKE}" --yes-wipe-all-disks

# Deploy host keys
deploy_host_private_keys

# Install EDK2 EFI Bootloader
#install_uefi_bootloader

# Install NixOS installation tools
add_missing_pkg nixos-install 'nixpkgs#nixos-install-tools'

# Hack-fix for missing 'mount' during activation.
ln -sf /nix/var/nix/profiles/system/sw/bin /mnt/sbin

# Install NixOS
nixos-install --flake "${FLAKE}"
