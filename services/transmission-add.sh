#!@shell@

RPC_ADDR="@rpcAddr@"
RPC_AUTH="@rpcUser@:@rpcPass@"

TORRENT_FILE="${1}"
DOWNLOAD_DIR="${2}"

if [[ ! -f "${TORRENT_FILE}" ]]; then
    echo "No such file: '${TORRENT_FILE}'" >&2
    exit 1
fi

echo "Adding torrent: '$(@coreutils@/bin/basename "${TORRENT_FILE}")'"
echo "Download dir: '${DOWNLOAD_DIR}'"

exec @transmission@/bin/transmission-remote ${RPC_ADDR} \
  --no-trash-torrent \
  --auth "${RPC_AUTH}" \
  --add "${TORRENT_FILE}" \
  --download-dir "${DOWNLOAD_DIR}"
