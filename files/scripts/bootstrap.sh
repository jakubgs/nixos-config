#!/usr/bin/env bash
set -euo pipefail

if [[ ! "${#}" -ge 1 ]]; then
    echo "Provide hostname to select config! Usage:" >&2
    echo "files/scripts/bootstrap.sh caspair 192.168.1.101" >&2
    exit 1
fi
ADDRESS="${2:-${1}.magi.lan}"

# Deploy host key necessary for Agenix decryption of secrets.
echo "Acquiring host private ED25519 key..." >&2
export ED25519_KEY=$(cd secrets; agenix -d hosts/keys/ed25519/${1}.age)

echo "Installing NixOS..." >&2
scp hosts/${1}/install.sh "${ADDRESS}:~/"
ssh "${ADDRESS}" "sudo --login --stdin ED25519_KEY='${ED25519_KEY}' ~/install.sh"
