#!/usr/bin/env bash
set -euo pipefail

function add_missing_pkg() {
    local command=${1} package=${2}
    command -v ${command} 2>&1 >/dev/null && return
    nix --extra-experimental-features 'nix-command flakes' \
        profile add ${package}
}

HOSTNAME="${1:-${HOSTNAME}}"
TARGET_MOUNT='/mnt'
TARGET_SSH_CONFIG_DIR="${TARGET_MOUNT}/etc/ssh"
ED25519_PRIV_KEY="${TARGET_MOUNT}/ssh_host_ed25519_key"
ED25519_PUB_KEY="${TARGET_MOUNT}/ssh_host_ed25519_key.pub"

# Install Agenix
add_missing_pkg agenix 'github:ryantm/agenix'

cd secrets/
cat hosts/${HOSTNAME}/ssh/ed25519.pub > "${ED25519_PUB_KEY}"
agenix -d hosts/${HOSTNAME}/ssh/ed25519.age > "${ED25519_PRIV_KEY}"
