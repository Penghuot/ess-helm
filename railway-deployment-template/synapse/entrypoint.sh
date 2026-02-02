#!/bin/sh
set -e

echo "=================================================="
echo "Synapse Railway Deployment - Starting"
echo "=================================================="

# Validate required environment variables
REQUIRED_VARS="SYNAPSE_SERVER_NAME SYNAPSE_PUBLIC_BASEURL DATABASE_URL SYNAPSE_REGISTRATION_SHARED_SECRET SYNAPSE_MACAROON_SECRET_KEY SYNAPSE_FORM_SECRET SYNAPSE_SIGNING_KEY"

for var in $REQUIRED_VARS; do
    eval value=\$$var
    if [ -z "$value" ]; then
        echo "ERROR: Missing required environment variable: $var"
        exit 1
    fi
done

echo "✓ All required environment variables are set"

# Generate homeserver.yaml from template
echo "Generating homeserver.yaml..."
envsubst < /homeserver.yaml.template > /data/homeserver.yaml
echo "✓ homeserver.yaml generated"

# Copy log config (static file)
cp /data/log.config.yaml /data/log.config.yaml
echo "✓ log.config.yaml ready"

# Write signing key
SIGNING_KEY_PATH="/data/${SYNAPSE_SERVER_NAME}.signing.key"
echo "Writing signing key..."
echo "$SYNAPSE_SIGNING_KEY" > "$SIGNING_KEY_PATH"
chmod 600 "$SIGNING_KEY_PATH"
echo "✓ signing key written"

echo "=================================================="
echo "Starting Synapse homeserver..."
echo "Server Name: $SYNAPSE_SERVER_NAME"
echo "Public URL: $SYNAPSE_PUBLIC_BASEURL"
echo "=================================================="

exec python -m synapse.app.homeserver -c /data/homeserver.yaml
