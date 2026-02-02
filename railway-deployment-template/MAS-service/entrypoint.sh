#!/bin/sh
set -e

echo "=================================================="
echo "MAS Railway Deployment - Starting"
echo "=================================================="

# Validate required environment variables
REQUIRED_VARS="MAS_PUBLIC_BASE DATABASE_URL MAS_MATRIX_HOMESERVER MAS_MATRIX_ENDPOINT MAS_MATRIX_SECRET MAS_CLIENT_SECRET MAS_ENCRYPTION_SECRET MAS_SIGNING_KEY"

for var in $REQUIRED_VARS; do
    eval value=\$$var
    if [ -z "$value" ]; then
        echo "ERROR: Missing required environment variable: $var"
        exit 1
    fi
done

echo "✓ All required environment variables are set"

# Generate configuration from template
echo "Generating config.yaml from template..."
envsubst < /config.yaml.template > /config.yaml

echo "✓ Configuration file generated"

# Set config path for MAS
export MAS_CONFIG_PATH=/config.yaml

echo "==================================================" 
echo "Starting MAS server..."
echo "Public Base: $MAS_PUBLIC_BASE"
echo "Matrix Homeserver: $MAS_MATRIX_HOMESERVER"
echo "=================================================="

# Start MAS server
exec mas-cli server
