#!@shell@

WATCH_DIR="${1}"
DOWNLOAD_DIR="${2}"

if [[ -z "${WATCH_DIR}" ]]; then
  echo "No directory to watch specified!" >&2
  exit 1
fi

@inotifytools@/bin/inotifywait \
  --monitor \
  --recursive \
  --event=create \
  --event=close_write \
  --format='%w|%f' \
  ${WATCH_DIR} | {
    while IFS='|' read -r PATH FILE; do
      FULLPATH="${PATH}${FILE}"
      SUBDIR="${PATH#$WATCH_DIR/}"

      if [[ ! -f "${FULLPATH}" ]]; then
        echo "No such file: '${FULLPATH}'"
        continue
      fi
      if [[ -d "${FULLPATH}" ]]; then
        echo "New directory created: '${FULLPATH}'"
        continue
      fi
      if [[ "${FULLPATH}" != *.torrent ]]; then
        echo "Not a torrent file: '${FULLPATH}'"
        continue
      fi

      @addTorrentScript@ "${FULLPATH}" "${DOWNLOAD_DIR}/${SUBDIR}"

      if [[ $? -eq 0 ]]; then
        @coreutils@/bin/rm -vf "${FULLPATH}"
      else
        @coreutils@/bin/mv "${FULLPATH}" "${FULLPATH}.failed"
        echo "Failed to add torrent!"
      fi
    done 
  }
