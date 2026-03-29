#!/usr/bin/env bash
set -o pipefail

GIT_ROOT=$(cd "${BASH_SOURCE%/*}" && git rev-parse --show-toplevel)
DOMAIN='magi.vpn'

function keyscan() {
    OUTPUT=$(ssh-keyscan -T 1 -t ed25519 "${1}.${DOMAIN}")
    if [[ -z "${OUTPUT}" ]]; then
        echo "# ${1}.${DOMAIN}:22 SSH key not found!" >&2
        return
    fi
    echo "${OUTPUT}" \
        | awk '/ssh-ed25519/{printf "%s %s", $2, $3}' \
        | tee "${GIT_ROOT}/secrets/hosts/${1%.*}/ssh/ed25519.pub"
    echo
}

if [[ -n "${1}" ]]; then
    keyscan "${1}"
else
    for HOST_PATH in "${GIT_ROOT}"/secrets/hosts/*; do
        keyscan "$(basename "${HOST_PATH}")"
    done
fi
