#!/bin/bash
set -e

echo "=== Synapse Startup Script ==="

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "PostgreSQL is ready!"

# Generate or restore signing key
if [ -n "$SYNAPSE_SIGNING_KEY" ]; then
  echo "Using signing key from environment variable"
  echo "$SYNAPSE_SIGNING_KEY" > /data/keys/signing.key
else
  if [ ! -f /data/keys/signing.key ]; then
    echo "Generating new signing key..."
    python -m synapse.app.homeserver \
      --config-path /data/homeserver.yaml \
      --generate-keys
    echo "Signing key generated!"
    echo ""
    echo "============================================"
    echo "IMPORTANT: Save this signing key!"
    cat /data/keys/signing.key
    echo "============================================"
    echo "Add this to Railway environment variables as:"
    echo "SYNAPSE_SIGNING_KEY=<the key above>"
    echo "============================================"
  else
    echo "Using existing signing key from volume"
  fi
fi

# Ensure correct permissions
chmod 644 /data/keys/signing.key

# Run database migrations if needed
echo "Running database check..."
python -m synapse.app.homeserver \
  --config-path /data/homeserver.yaml \
  --generate-missing-configs

echo "Starting Synapse..."
exec python -m synapse.app.homeserver \
  --config-path /data/homeserver.yaml