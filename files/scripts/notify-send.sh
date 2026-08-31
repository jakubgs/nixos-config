#!/usr/bin/env bash
set -euo pipefail

TIMEOUT=0

usage() {
    echo "Usage: notify-send [-t TIME_MS] TITLE [MESSAGE]"
}

lua_quote() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\r'/\\r}
    s=${s//$'\t'/\\t}
    printf '"%s"' "$s"
}

while getopts ":t:h" opt; do
    case "$opt" in
        # notify-send uses milliseconds; naughty uses seconds.
        t)  TIMEOUT=$(awk "BEGIN { print $OPTARG / 1000 }");;
        h)  usage; exit 0;;
        :)  echo "Option -$OPTARG requires argument" >&2; exit 1;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage >&2; exit 1;;
    esac
done

shift $((OPTIND - 1))

if (( $# < 1 )); then
    usage >&2
    exit 1
fi

TITLE=$1
shift

if (( $# > 0 )); then
    MESSAGE="$*"
else
    MESSAGE=""
fi

# Ensure we connect to desktop user Awesome DBUS session.
AUID=$(id -u "${AWESOME_USER:-jakubgs}")
export XDG_RUNTIME_DIR="/run/user/${AUID}"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

TITLE_LUA=$(lua_quote "$TITLE")
MESSAGE_LUA=$(lua_quote "$MESSAGE")

exec runuser -u "${AWESOME_USER}" awesome-client <<EOF
local naughty = require("naughty")

naughty.notify({
    title   = $TITLE_LUA,
    text    = $MESSAGE_LUA,
    timeout = $TIMEOUT,
    screen  = 1,
    margin  = 8,
    width   = 500
})
EOF
