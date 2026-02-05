#!/usr/bin/env bash
set -euo pipefail

: "${HOMESERVER_URL:?Must set HOMESERVER_URL}"

SERVER_NAME="${SERVER_NAME:-matrix-local}"
ELEMENT_DEFAULT_THEME="${ELEMENT_DEFAULT_THEME:-light}"

sed \
  -e "s#{{HOMESERVER_URL}}#${HOMESERVER_URL}#g" \
  -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" \
  -e "s#{{ELEMENT_DEFAULT_THEME}}#${ELEMENT_DEFAULT_THEME}#g" \
  /app/config.template.json > /app/config.json

exec nginx -g "daemon off;"
