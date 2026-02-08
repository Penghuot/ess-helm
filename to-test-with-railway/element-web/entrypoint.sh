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
ELEMENT_CALL_URL="${ELEMENT_CALL_URL:-}"
ELEMENT_WEB_URL="${ELEMENT_WEB_URL:-https://web-element-production-1fad.up.railway.app}"
LK_JWT_SERVICE_URL="${LK_JWT_SERVICE_URL:-}"

echo "Configuring Element Web..."
echo "Homeserver: $HOMESERVER_URL"
echo "MAS: $MAS_URL"
echo "Element Web URL: $ELEMENT_WEB_URL"
echo "Element Call: ${ELEMENT_CALL_URL:-Not configured}"
echo "LiveKit JWT Service: ${LK_JWT_SERVICE_URL:-Not configured}"

# Substitute placeholders in template
sed \
  -e "s#{{HOMESERVER_URL}}#${HOMESERVER_URL}#g" \
  -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" \
  -e "s#{{MAS_URL}}#${MAS_URL}#g" \
  -e "s#{{ELEMENT_WEB_CLIENT_ID}}#${ELEMENT_WEB_CLIENT_ID}#g" \
  -e "s#{{ELEMENT_WEB_URL}}#${ELEMENT_WEB_URL}#g" \
  -e "s#{{ELEMENT_DEFAULT_THEME}}#${ELEMENT_DEFAULT_THEME}#g" \
  -e "s#{{ELEMENT_CALL_URL}}#${ELEMENT_CALL_URL}#g" \
  -e "s#{{LK_JWT_SERVICE_URL}}#${LK_JWT_SERVICE_URL}#g" \
  /app/config.template.json > /app/config.json

echo "Element Web configured successfully!"

# Start nginx (default in element-web image)
exec nginx -g "daemon off;"
