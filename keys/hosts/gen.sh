#!/usr/bin/env bash
set -o pipefail

THIS_DIR=$(dirname "${0}")
DOMAIN='magi.vpn'

function keyscan() {
    OUTPUT=$(ssh-keyscan -T 1 -t ed25519 "${1}.${DOMAIN}")
    if [[ -z "${OUTPUT}" ]]; then
        echo "# ${1}.${DOMAIN}:22 SSH key not found!" >&2
        return
    fi
    echo "${OUTPUT}" \
        | awk '{printf "%s %s", $2, $3}' \
        | tee "${THIS_DIR}/${1%.*}"
    echo
}

if [[ -n "${1}" ]]; then
    keyscan "${1}"
else
    for HOST_PATH in "${THIS_DIR}"/../../hosts/*; do
        keyscan "$(basename "${HOST_PATH}")"
    done
fi
