#!@shell@
set -e
export PATH="@binPath@:${PATH}"

RPC_ADDR="@rpcAddr@"
# Credentials are in a JSON file.
RPC_CREDS="@rpcCreds@"
RPC_USER=$(jq -r '."rpc-username"' "${RPC_CREDS}")
RPC_PASS=$(jq -r '."rpc-password"' "${RPC_CREDS}")

TORRENT_FILE="${1}"
DOWNLOAD_DIR="${2}"

if [[ ! -f "${TORRENT_FILE}" ]]; then
    echo "No such file: '${TORRENT_FILE}'" >&2
    exit 1
fi

echo "Adding torrent: '$(basename "${TORRENT_FILE}")'"
echo "Download dir: '${DOWNLOAD_DIR}'"

exec transmission-remote ${RPC_ADDR} \
  --no-trash-torrent \
  --auth "${RPC_USER}:${RPC_PASS}" \
  --add "${TORRENT_FILE}" \
  --download-dir "${DOWNLOAD_DIR}"
