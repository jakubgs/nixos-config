#!/usr/bin/env bash

set -euo pipefail

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

# Ansure root permissions.
[[ $(id -u) -ne 0 ]] && { echo 'ERROR: Script needs to be run as root.' >&2; exit 1; }
# Necessary for deployment of secrets to work.
[[ -z "${ED25519_KEY:-}" ]] && { echo "No ED25519_KEY env var provided."; exit 1; }

# Show almost all commands executed.
set -x

export HOSTNAME='armisael'
export FLAKE="github:jakubgs/nixos-config#${HOSTNAME}"
export NIX_CONFIG='experimental-features = nix-command flakes'

# Install Disko
add_missing_pkg disko 'github:nix-community/disko/v1.13.0#disko-install'

# Clear Nix cache
rm -r /root/.cache/nix

# Re-create filesystem layout. DESTRUCTIVE!
disko --mode 'destroy,format,mount' --flake "${FLAKE}"

# Deploy host keys
deploy_host_private_keys

# Install NixOS installation tools
add_missing_pkg nixos-install 'nixpkgs#nixos-install-tools'

# Install NixOS operating system.
nixos-install --no-channel-copy --flake "${FLAKE}"

# Umount
disko --mode unmount --flake "${FLAKE}"
