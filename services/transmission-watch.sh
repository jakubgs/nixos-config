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
  --format='%e|%w|%f' \
  --event=create \
  --event=attrib \
  --event=moved_to \
  --include '.*.torrent$' \
  ${WATCH_DIR} | {
    while IFS='|' read -r EVENT DIR_PATH FILE_NAME; do
      FULLPATH="${DIR_PATH}${FILE_NAME}"
      SUBDIR="${DIR_PATH#$WATCH_DIR/}"

      if [[ ! -f "${FULLPATH}" ]]; then
        echo "No such file: '${FULLPATH}'"; continue
      elif [[ -d "${FULLPATH}" ]]; then
        echo "New directory created: '${FULLPATH}'"; continue
      fi

      @addTorrentScript@ "${FULLPATH}" "${DOWNLOAD_DIR}/${SUBDIR}"

      if [[ $? -eq 0 ]]; then
        echo "Removing torrent file: '${FULLPATH}'"
        @coreutils@/bin/rm -vf "${FULLPATH}"
      else
        echo "Failed to add torrent: '${FULLPATH}'"
        @coreutils@/bin/mv "${FULLPATH}" "${FULLPATH}.failed"
      fi
    done 
  }
