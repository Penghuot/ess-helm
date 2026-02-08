#!/bin/sh
set -eu

# Validate required environment variables
: "${LIVEKIT_URL:?Must set LIVEKIT_URL}"
: "${LIVEKIT_API_KEY:?Must set LIVEKIT_API_KEY}"
: "${LIVEKIT_API_SECRET:?Must set LIVEKIT_API_SECRET}"

echo "Configuring LiveKit JWT Service..."
echo "LiveKit URL: $LIVEKIT_URL"
echo "API Key: ${LIVEKIT_API_KEY:0:15}..."

# Set port (Railway sets PORT automatically)
export LK_JWT_PORT="${PORT:-8080}"

echo "Starting lk-jwt-service on port $LK_JWT_PORT..."

# Start the service
exec /lk-jwt-service
