#!@shell@

WATCH_DIR="${1}"
DOWNLOAD_DIR="${2}"
if [[ -z "${RPC_USER}" ]] || [[ -z "${RPC_USER}" ]]; then
    echo "WARNING: RPC Auth no configured!"
else
    RPC_AUTH="--auth ${RPC_USER}:${RPC_PASS}"
fi

if [[ -z "${WATCH_DIR}" ]]; then
  echo "No directory to watch specified!" >&2
  exit 1
fi

@inotifytools@/bin/inotifywait \
  --monitor \
  --recursive \
  --event=create \
  --event=attrib \
  --event=close_write \
  --format='%w %f' \
  ${WATCH_DIR} | {
    while IFS=' ' read -r PATH FILE; do
      FULLPATH="${PATH}${FILE}"

      if [[ -d "${FULLPATH}" ]]; then
        echo "New directory created: ${FULLPATH}"
        continue
      fi
      if [[ "${FULLPATH}" != *.torrent ]]; then
        echo "Not a torrent file: ${FULLPATH}"
        continue
      fi

      echo "Adding torrent: ${FULLPATH}";
      SUBDIR="${PATH#$WATCH_DIR/}"
      echo "Subfolder: ${DOWNLOAD_DIR}/${SUBDIR}"

      @transmission@/bin/transmission-remote ${RPC_ADDR} ${RPC_AUTH} \
        --no-trash-torrent \
        --add "${FULLPATH}" \
        --download-dir "${DOWNLOAD_DIR}/${SUBDIR}"

      if [[ $? -eq 0 ]]; then
        @coreutils@/bin/rm -vf "${FULLPATH}"
      else
        @coreutils@/bin/mv "${FULLPATH}" "${FULLPATH}.failed"
        echo "Failed to add torrent!"
      fi
    done 
  }
