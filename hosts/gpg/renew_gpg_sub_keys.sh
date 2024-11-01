#!/usr/bin/env bash

function gpg_list() {
    gpg \
        --list-secret-keys \
        --list-options show-unusable-subkeys \
        --with-subkey-fingerprints "${@}"
}
function gpg_keys_comment() {
    gpg_list "${KEYID}" | sed -e 's/^/# /'
    echo
}

export KEYID="${1:-30236E0B5767C9C5DC9E74A76295CD4EBA31C3EA}"

gpg_keys_comment

echo gpg --list-secret-keys --list-options show-unusable-subkeys --with-subkey-fingerprints "${KEYID}"

SUBIDS=$(
    gpg_list --with-colons "${KEYID}" \
        | awk -F':' '/fpr/{print $10}' \
        | grep -v "${KEYID}"
)
for SUBID in ${SUBIDS[@]}; do
    echo gpg --quick-set-expire "${KEYID}" 1y "${SUBID}"
done

echo gpg --list-secret-keys --list-options show-unusable-subkeys --with-subkey-fingerprints "${KEYID}"
echo gpg --send-keys "${KEYID}"
echo gpg --armor --export "${KEYID}" \> "${KEYID}_sub.pub"
echo gpg --armor --export-secret-subkeys "${KEYID}" \> "${KEYID}_sub.key"

echo
cat << EOF
# In order to upload the new keys to the device you will require Admin PIN.
#
# Upload each key using 'keytocard' command. The subkeys will be removed afterwards.

gpg --edit-key ${KEYID}

# Secret key is available.
#
# sec  rsa4096/E7D921BDE461C04E
#      created: 2023-11-12  expires: never       usage: SC
#      trust: ultimate      validity: ultimate
# ssb  rsa4096/8E74F2BE0096AA95
#      created: 2023-11-12  expires: 2025-11-11  usage: A
# ssb  rsa4096/9AD3C958522E45BF
#      created: 2023-11-12  expires: 2025-11-11  usage: E
# ssb  rsa4096/29BFBB036D62C78C
#      created: 2023-11-12  expires: 2025-11-11  usage: S
# [ultimate] (1).  Joe Example (My key) <joe@example.org>
#
# gpg> key 1
#
# gpg> keytocard
# Please select where to store the key:
#    (3) Authentication key
# Your selection? 3
EOF
