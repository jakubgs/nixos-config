#!/usr/bin/env bash
# This script creates an encrypted ISO image for offline backups.
# Source: https://www.frederickding.com/posts/2017/08/luks-encrypted-dvd-bd-data-disc-guide-273316/

[[ "$EUID" -ne 0 ]] && { echo "ERROR: Must be run as root!"; exit 1; }

DEVICE="${1:-/dev/sr0}"
LOOPDEV="${LOOPDEV:-loop20}"
VOLUME="${VOLUME:-volume1}"
LOOPPATH="/dev/${LOOPDEV}"
MOUNTPATH="/mnt/${LOOPDEV}"

set -e
set -x

losetup --detach "${LOOPPATH}" || true
losetup "${LOOPPATH}" "${DEVICE}"
lsblk "${LOOPPATH}"
cryptsetup open "${LOOPPATH}" "${VOLUME}"
mkdir -p "${MOUNTPATH}"
mount -t udf -o ro "/dev/mapper/${VOLUME}" "${MOUNTPATH}"
