#!/usr/bin/env bash
set -euo pipefail

function show_help() {
  cat << EOF
Usage: usb_backup.sh [-f|-s|-m|-L|-h] [-l ${LABEL}] [-u ${USERNAME}] -d /dev/sdx

 -h - Show this help message.
 -L - List USB devices.
 -d - Specify device name. Mandatory.
 -l - Specify label for LUKS device.
 -u - Specify username for home dir.
 -f - Format specified defice for secret backups.
 -m - Mount the device and let user copy.
 -s - Sync pre-defined assets to device.

EOF
}

function list_devices() {
    echo -e "Here are some options:\n"
    lsblk -S | grep -e VENDOR -e usb
}

function error() {
    echo "ERROR: $1" >&2
}

function bytes_to_mb() {
    [[ "${1}" -lt 0 ]] && echo -n '-'
    numfmt --to iec --format "%.2f" "${1#-}"
}

function cleanup_umount() {
    if mountpoint -q "/mnt/${LABEL}/"; then
        echo
        du -hsc "/mnt/${LABEL}/"*
        echo
        df -h "${DEVICE}"
        echo
        echo "Removing device..."
    fi
    umount -qf "/mnt/${LABEL}"
    rm -r "/mnt/${LABEL}"
    cryptsetup luksClose "${LABEL}"
}

function check_size() {
    local -r ASSET="${1}"
    local -r TARGET="${2}"
    local -r SIZE_NOW=$(du --apparent-size -sb "${ASSET}" | cut -f1)
    local SIZE_OLD=0
    if [[ -d "${TARGET}" ]]; then
        SIZE_OLD=$(du --apparent-size -sb "${TARGET}" | cut -f1)
    fi
    local REMAINING_SIZE=$((SIZE_NOW - SIZE_OLD))
    echo "${REMAINING_SIZE}"
}

function format_device() {
    read -r -p "Are you sure you want to format ${DEVICE} ? <y/N> " prompt
    if [[ ! $prompt =~ [yY](es)* ]]; then
        exit 0
    fi
    cryptsetup luksFormat -y "${DEVICE}" "${PASS_FILE}"
    cryptsetup luksOpen --key-file "${PASS_FILE}" "${DEVICE}" "${LABEL}"
    mkfs.ext4 -m 0 -L "${LABEL}" "/dev/mapper/${LABEL}"
    sync && sleep 2
    cryptsetup luksClose "${LABEL}"
}

function mount_device() {
    echo "Mounting device: ${DEVICE} -> /dev/mapper/${LABEL} -> /mnt/${LABEL}"
    umount "/mnt/${LABEL}" 2>/dev/null
    # decrypt
    cryptsetup luksOpen -d "${PASS_FILE}" "${DEVICE}" "${LABEL}"
    local DEVICE="/dev/mapper/${LABEL}"
    mkdir -p "/mnt/${LABEL}"
    mount "${DEVICE}" "/mnt/${LABEL}"
}

function sync_assets() {
    local NAME TARGET FREE_B LEFT_B
    for ASSET in "${ASSETS[@]}"; do
        NAME=$(basename "${ASSET}")
        TARGET="/mnt/${LABEL}/${NAME#.}"
        FREE_B=$(df -P "/mnt/${LABEL}" | awk '/dev/{print ($4 * 1024)}')
        LEFT_B=$(check_size "$ASSET" "$TARGET")
        if [[ ${LEFT_B} -gt 0 ]] && [[ ${FREE_B} -lt ${LEFT_B} ]]; then
            echo "* Skipping: ${ASSET} - Not enough space. ($(bytes_to_mb "${LEFT_B}"))"
            continue
        fi
        echo "* Copying: ${ASSET} -> ${TARGET} ($(bytes_to_mb "${LEFT_B}"))"
        rsync --delete -aqr "${ASSET}/." "${TARGET}"
    done
    echo
    echo "Syncing..."
    sync
}

function prompt_user() {
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


# Initialize our own variables:
USERNAME='jakubgs'
LABEL="keychain_$(date '+%Y%m%d_%H%M%S')"
DEVICE=''
LIST=0
MOUNT=0
FORMAT=0
SYNC=0

# Parse arguments
while getopts "Lmsfu:d:l:h" opt; do
  case "$opt" in
    L) LIST=1 ;;
    m) MOUNT=1 ;;
    s) SYNC=1 ;;
    f) FORMAT=1 ;;
    u) USERNAME="${OPTARG}" ;;
    d) DEVICE="${OPTARG}" ;;
    l) LABEL="${OPTARG}" ;;
    h) show_help; list_devices; exit 0 ;;
    *) show_help; list_devices; exit 1 ;;
  esac
done
[ "${1:-}" = "--" ] && shift

# File with decrypting password
PASS_FILE="/home/${USERNAME}/.usb_backup_pass"
# Pre-defined assets to sync, order matters, too big are skipped.
ASSETS=(
    "/home/$USERNAME/.password-store"
    "/home/$USERNAME/.gnupg"
    "/home/$USERNAME/.ssh"
    "/mnt/git"
    "/mnt/data/documents"
    "/mnt/data/company"
    "/mnt/data/important"
    "/mnt/photos"
)

[[ $UID -ne 0 ]]                && error "This script requires root piviliges!" && exit 1
[[ -z "${DEVICE}" ]]            && error "No device specified with -d flag!"    && list_devices && exit 1
[[ -z "${LABEL}" ]]             && error "Label cannot be an empty string!"     && exit 1
[[ ! -f "${PASS_FILE}" ]]       && error "No password file found!"              && exit 1
[[ -b "/dev/mapper/${LABEL}" ]] && error "Label already exists: ${LABEL}"       && exit 1
[[ ! "${DEVICE}" =~ /dev/.* ]]  && DEVICE="/dev/${DEVICE}"
[[ ! -b "${DEVICE}" ]]          && error "No such device exists: ${DEVICE}"     && exit 1

if [[ "${LIST}" -eq 1 ]]; then
    list_devices
elif [[ "${FORMAT}" -eq 1 ]]; then
    format_device
elif [[ "${MOUNT}" -eq 1 ]]; then
    trap cleanup_umount EXIT ERR INT QUIT
    mount_device && prompt_user
elif [[ "${SYNC}" -eq 1 ]]; then
    trap cleanup_umount EXIT ERR INT QUIT
    mount_device && sync_assets
else
    show_help; list_devices
    exit 1
fi

echo "SUCCESS!"
