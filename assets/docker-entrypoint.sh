#!/bin/sh

set -euo pipefail

ilias_auto_config_server() {
  echo "Configuring server ..."
  env \
    ILIAS_CHAT_PORT="${ILIAS_CHAT_PORT}" \
    ILIAS_CHAT_ADDRESS="${ILIAS_CHAT_ADDRESS-127.0.0.1}" \
    ILIAS_CHAT_LOG_DIR="${ILIAS_CHAT_LOG_DIR}" \
    ILIAS_CHAT_DELETION_MODE="${ILIAS_CHAT_DELETION_MODE-0}" \
    ILIAS_CHAT_DELETION_UNIT="${ILIAS_CHAT_DELETION_UNIT-years}" \
    ILIAS_CHAT_DELETION_VALUE="${ILIAS_CHAT_DELETION_VALUE-1}" \
    ILIAS_CHAT_DELETION_TIME="${ILIAS_CHAT_DELETION_TIME-06:30}" \
    node /ilias_auto_config_server.js > "${ILIAS_CHAT_CONFIG_DIR}"/server.cfg
}

ilias_auto_config_client() {
  echo "Configuring client ..."
  env \
    ILIAS_CHAT_CLIENT_NAME="${ILIAS_CHAT_CLIENT_NAME}" \
    ILIAS_CHAT_AUTH_KEY="${ILIAS_CHAT_AUTH_KEY}" \
    ILIAS_CHAT_AUTH_SECRET="${ILIAS_CHAT_AUTH_SECRET}" \
    ILIAS_CHAT_DB_HOST="${ILIAS_CHAT_DB_HOST}" \
    ILIAS_CHAT_DB_PORT="${ILIAS_CHAT_DB_PORT-3306}" \
    ILIAS_CHAT_DB_NAME="${ILIAS_CHAT_DB_NAME}" \
    ILIAS_CHAT_DB_USER="${ILIAS_CHAT_DB_USER}" \
    ILIAS_CHAT_DB_PASS="${ILIAS_CHAT_DB_PASS}" \
    node /ilias_auto_config_server.js > "${ILIAS_CHAT_CONFIG_DIR}"/client.cfg
}

ilias_chat_configure() {
  echo "Checking if ILIAS chat needs configuration (IAC: ${ILIAS_AUTO_CONFIGURE+1}) ..."
  if [ -n "${ILIAS_AUTO_CONFIGURE+1}" ] ||  [ ! -f "${ILIAS_CHAT_CONFIG_DIR}"/server.cfg ]; then
    ilias_auto_config_server
  fi
  if [ -n "${ILIAS_AUTO_CONFIGURE+1}" ] ||  [ ! -f "${ILIAS_CHAT_CONFIG_DIR}"/client.cfg ]; then
    ilias_auto_config_client
  fi
  mkdir -p /var/log/chat
  chown "${ILIAS_RUN_USER}:${ILIAS_RUN_GROUP}" /var/log/chat
}

ilias_chat_start_server() {
  echo "Starting up ILIAS chat server ..."
  exec gosu "${ILIAS_RUN_USER}:${ILIAS_RUN_GROUP}" \
	"node" "${ILIAS_CHAT_HOME}/chat" \
        "${ILIAS_CHAT_CONFIG_DIR}/server.cfg" "${ILIAS_CHAT_CONFIG_DIR}/client.cfg"
}

ilias_chat_configure

case ${1} in
  app:serve)
    ilias_chat_start_server
    ;;
  *)
    exec "$@"
    ;;
esac

