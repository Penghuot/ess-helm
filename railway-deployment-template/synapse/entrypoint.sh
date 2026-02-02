#!/bin/sh
set -e

echo "=================================================="
echo "Synapse Railway Deployment - Starting"
echo "=================================================="

# Required environment variables
REQUIRED_VARS="SYNAPSE_SERVER_NAME SYNAPSE_PUBLIC_BASEURL DATABASE_URL SYNAPSE_REGISTRATION_SHARED_SECRET SYNAPSE_MACAROON_SECRET_KEY SYNAPSE_FORM_SECRET"

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

# Generate log config file based on domain
LOG_CONFIG_PATH="/data/${SYNAPSE_SERVER_NAME}.log.config"
echo "Generating log config..."
cp /data/log.config.yaml "$LOG_CONFIG_PATH"
echo "✓ log config generated at $LOG_CONFIG_PATH"

# Generate signing key file based on domain
SIGNING_KEY_PATH="/data/${SYNAPSE_SERVER_NAME}.signing.key"
echo "Generating signing key..."
if [ -z "$SYNAPSE_SIGNING_KEY" ]; then
    # Auto-generate if not provided
    python -m synapse.app.homeserver --generate-keys "$SIGNING_KEY_PATH"
else
    echo "$SYNAPSE_SIGNING_KEY" > "$SIGNING_KEY_PATH"
fi
chmod 600 "$SIGNING_KEY_PATH"
echo "✓ signing key ready at $SIGNING_KEY_PATH"

echo "=================================================="
echo "Starting Synapse homeserver..."
echo "Server Name: $SYNAPSE_SERVER_NAME"
echo "Public URL: $SYNAPSE_PUBLIC_BASEURL"
echo "=================================================="

exec python -m synapse.app.homeserver -c /data/homeserver.yaml
