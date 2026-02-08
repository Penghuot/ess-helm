#!/bin/sh
set -eu

# Validate required environment variables
: "${HOMESERVER_URL:?Must set HOMESERVER_URL}"
: "${LIVEKIT_URL:?Must set LIVEKIT_URL}"
: "${LIVEKIT_JWT_SERVICE_URL:?Must set LIVEKIT_JWT_SERVICE_URL}"

# Optional with defaults
SERVER_NAME="${SERVER_NAME:-matrix-railway}"

echo "Configuring Element Call..."
echo "Homeserver: $HOMESERVER_URL"
echo "Server Name: $SERVER_NAME"
echo "LiveKit URL: $LIVEKIT_URL"
echo "LiveKit JWT Service: $LIVEKIT_JWT_SERVICE_URL"

# Generate config.json from template
sed \
  -e "s#{{HOMESERVER_URL}}#${HOMESERVER_URL}#g" \
  -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" \
  -e "s#{{LIVEKIT_URL}}#${LIVEKIT_URL}#g" \
  -e "s#{{LIVEKIT_JWT_SERVICE_URL}}#${LIVEKIT_JWT_SERVICE_URL}#g" \
  /app/config.template.json > /app/config.json

echo "Element Call configuration complete!"
cat /app/config.json

# Start nginx
exec nginx -g 'daemon off;'
