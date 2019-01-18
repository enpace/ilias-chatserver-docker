#!/bin/sh

set -euo pipefail
IFS=$'\n\t'

ILIAS_CHAT_HEARTBEAT_URL="http://127.0.0.1:${ILIAS_CHAT_PORT}/backend/Heartbeat/onscreen"

# Low level health check
HTTP_CODE=$(curl \
  -sw '%{http_code}' \
  -o /dev/null \
  --max-time 5 \
  "${ILIAS_CHAT_HEARTBEAT_URL}" \
)
[                -n "$?" ] || exit 1
[ "${HTTP_CODE}" -ge 200 ] && \
[ "${HTTP_CODE}" -lt 300 ] || exit 1

