#!/usr/bin/env bash

set -e

# This script creates an encrypted ISO image for offline backups.
# Source: https://www.frederickding.com/posts/2017/08/luks-encrypted-dvd-bd-data-disc-guide-273316/
#
# Mounting disc:
#
# sudo losetup /dev/loop10 /dev/sr0
# sudo cryptsetup -r luksOpen /dev/loop10 volume1
# sudo mount -t udf -o ro /dev/mapper/volume1 /media/datadisc
#
# Unmounting disc:
#
# sudo umount /dev/mapper/volume1
# sudo cryptsetup luksClose volume1
# sudo losetup -d /dev/loop10
#
# Known Issues:
# * 'losetup: /dev/sr0: failed to set up loop device: Device or resource busy'
#   - Caused by trying to use a `/dev/loop*` device that's already used.

if [[ ${UID} -ne 0 ]]; then
    echo "This script needs to be run as root!" >&2
    exit 1
fi

if [[ "${#}" -eq 1 ]] && [[ "${1}" == "-u" ]]; then
    echo "Unmounting..."

fi

if [[ "${#}" -ne 3 ]]; then
    echo "Usage: ${0} <ISO_PATH> <ISO_LABEL> <MOUNT_POINT>" >&2
    exit 1
fi

ISO_SIZE="${ISO_SIZE:-2600M}"
ISO_PATH="${1}"
ISO_LABEL="${2}"
MOUNT_POINT="${3}"
LOOP_DEVICE="/dev/loop19"
MAPPER_DEV_NAME="backup"
MAPPER_DEV_PATH="/dev/mapper/${MAPPER_DEV_NAME}"

function _create() {
    # Allocate an ISO image file
    truncate -s "${ISO_SIZE}" "${ISO_PATH}"
    # Mount ISO via loopback device
    export LOOP_DEVICE=$(losetup --show -f "${ISO_PATH}")
    # Format with LUKS filesystem
    cryptsetup -q luksFormat "${LOOP_DEVICE}"
    # Map the new LUKS filesystem to a block device
    cryptsetup luksOpen "${LOOP_DEVICE}" "${MAPPER_DEV_NAME}"
    # Created UDF filesystem on the device
    mkudffs --label="${ISO_LABEL}" "${MAPPER_DEV_PATH}"
}

function _mount() {
    # Mount ISO via loopback device
    export LOOP_DEVICE=$(losetup --show -f "${ISO_PATH}")
    # Map the new LUKS filesystem to a block device
    if [[ -b "${MAPPER_DEV_NAME}" ]]; then
        cryptsetup luksOpen "${LOOP_DEVICE}" "${MAPPER_DEV_NAME}"
    fi
    # Mount the filesystem
    mkdir -p "${MOUNT_POINT}"
    if ! mountpoint -q "${MOUNT_POINT}"; then
        mount -t udf "${MAPPER_DEV_PATH}" "${MOUNT_POINT}"
    fi
}

function _umount() {
    set +e
    umount "${MAPPER_DEV_PATH}"
    cryptsetup luksClose "${MAPPER_DEV_NAME}"
    losetup -d "${LOOP_DEVICE}"
}

function _prompt() {
    echo "Have you copied all the necessary files?"
    select RESP in "yes" "no"; do
        if [[ -z "${RESP}" ]]; then
            echo "Unclear input!" >&2;
            continue
        fi
        case "${RESP}" in
            yes) return;;
            no)  continue;;
        esac
    done
}

echo "Creating..."

trap _umount EXIT ERR INT QUIT
_create
_mount
_prompt

echo "SUCCESS!"
