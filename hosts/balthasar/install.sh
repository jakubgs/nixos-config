#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'ERROR: Script needs to be run as root.' >&2
    exit 1
fi

export NIX_CONFIG='experimental-features = nix-command flakes'
export FLAKE='github:jakubgs/nixos-config#balthasar'

# Install Disko to format local storage.
nix profile install 'github:nix-community/disko/v1.11.0'

# Re-create filesystem layout. DESTRUCTIVE!
disko --mode 'destroy,format,mount' --flake "${FLAKE}"

# Install NixOS operating system.
nixos-install --no-channel-copy --flake "${FLAKE}"

# Export zpool
umount /mnt/nix /mnt/home /mnt
zpool export rpool
