#!/bin/sh
set -eu

# Require HOMESERVER_URL and MAS_URL to be set
: "${HOMESERVER_URL:?Must set HOMESERVER_URL}"
: "${MAS_URL:?Must set MAS_URL}"
: "${ELEMENT_WEB_CLIENT_ID:?Must set ELEMENT_WEB_CLIENT_ID}"

# Strip optional surrounding quotes from client ID
ELEMENT_WEB_CLIENT_ID="${ELEMENT_WEB_CLIENT_ID%\"}"
ELEMENT_WEB_CLIENT_ID="${ELEMENT_WEB_CLIENT_ID#\"}"

# Optional defaults
SERVER_NAME="${SERVER_NAME:-matrix-railway}"
ELEMENT_DEFAULT_THEME="${ELEMENT_DEFAULT_THEME:-light}"

# Substitute placeholders in template
sed \
  -e "s#{{HOMESERVER_URL}}#${HOMESERVER_URL}#g" \
  -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" \
  -e "s#{{MAS_URL}}#${MAS_URL}#g" \
  -e "s#{{ELEMENT_WEB_CLIENT_ID}}#${ELEMENT_WEB_CLIENT_ID}#g" \
  -e "s#{{ELEMENT_DEFAULT_THEME}}#${ELEMENT_DEFAULT_THEME}#g" \
  /app/config.template.json > /app/config.json

# Start nginx (default in element-web image)
exec nginx -g "daemon off;"
