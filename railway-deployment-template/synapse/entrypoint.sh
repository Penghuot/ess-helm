#!/bin/sh
set -e

echo "=================================================="
echo "Synapse Railway Deployment - Starting"
echo "=================================================="

# Parse DATABASE_URL if provided by Railway
if [ -n "$DATABASE_URL" ]; then
    # Extract components from postgresql://user:pass@host:port/db
    export PGUSER=$(echo $DATABASE_URL | sed -n 's|.*://\([^:]*\):.*|\1|p')
    export PGPASSWORD=$(echo $DATABASE_URL | sed -n 's|.*://[^:]*:\([^@]*\)@.*|\1|p')
    export PGHOST=$(echo $DATABASE_URL | sed -n 's|.*@\([^:]*\):.*|\1|p')
    export PGPORT=$(echo $DATABASE_URL | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
    export PGDATABASE=$(echo $DATABASE_URL | sed -n 's|.*/\([^?]*\).*|\1|p')
fi

# Validate required environment variables
REQUIRED_VARS="SYNAPSE_SERVER_NAME SYNAPSE_PUBLIC_BASEURL PGUSER PGPASSWORD PGHOST PGPORT PGDATABASE SYNAPSE_REGISTRATION_SHARED_SECRET SYNAPSE_MACAROON_SECRET_KEY SYNAPSE_FORM_SECRET"

for var in $REQUIRED_VARS; do
    eval value=\$$var
    if [ -z "$value" ]; then
        echo "ERROR: Missing required environment variable: $var"
        exit 1
    fi
done

echo "✓ All required environment variables are set"

# Set defaults for optional variables
export PGPORT=${PGPORT:-5432}
export SYNAPSE_ENABLE_REGISTRATION=${SYNAPSE_ENABLE_REGISTRATION:-true}
export SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=${SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION:-true}
export SYNAPSE_REPORT_STATS=${SYNAPSE_REPORT_STATS:-true}

# Generate configuration from template
echo "Generating homeserver.yaml from template..."
envsubst < /homeserver.yaml.template > /data/homeserver.yaml

echo "✓ Configuration file generated"

# Handle signing key
SIGNING_KEY_PATH="/data/${SYNAPSE_SERVER_NAME}.signing.key"

if [ -n "$SYNAPSE_SIGNING_KEY" ]; then
    echo "Using signing key from environment variable..."
    echo "$SYNAPSE_SIGNING_KEY" > "$SIGNING_KEY_PATH"
    chmod 600 "$SIGNING_KEY_PATH"
    echo "✓ Signing key written"
elif [ ! -f "$SIGNING_KEY_PATH" ]; then
    echo "Generating new signing key..."
    python -m synapse.app.homeserver \
        --server-name="$SYNAPSE_SERVER_NAME" \
        --config-path=/data/homeserver.yaml \
        --generate-keys
    echo "✓ New signing key generated"
    echo "IMPORTANT: Save this key to SYNAPSE_SIGNING_KEY environment variable"
else
    echo "✓ Using existing signing key"
fi

echo "=================================================="
echo "Starting Synapse homeserver..."
echo "Server Name: $SYNAPSE_SERVER_NAME"
echo "Public URL: $SYNAPSE_PUBLIC_BASEURL"
echo "=================================================="

exec python -m synapse.app.homeserver \
    --server-name="$SYNAPSE_SERVER_NAME" \
    --config-path=/data/homeserver.yaml
