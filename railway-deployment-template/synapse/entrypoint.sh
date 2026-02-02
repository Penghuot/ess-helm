#!/bin/bash
# ============================================================================
# Synapse Entrypoint Script
# ============================================================================
# This script:
# 1. Validates required environment variables
# 2. Generates configuration from template
# 3. Creates signing key if missing
# 4. Runs database migrations
# 5. Starts Synapse server
# ============================================================================

set -e

echo "=================================================="
echo "Synapse Railway Deployment - Starting"
echo "=================================================="

# ============================================================================
# Step 1: Validate Required Environment Variables
# ============================================================================

REQUIRED_VARS=(
    "PGHOST"
    "PGUSER"
    "PGPASSWORD"
    "PGDATABASE"
    "SYNAPSE_SERVER_NAME"
    "SYNAPSE_PUBLIC_BASEURL"
    "SYNAPSE_REGISTRATION_SHARED_SECRET"
    "SYNAPSE_MACAROON_SECRET_KEY"
    "SYNAPSE_FORM_SECRET"
)

echo "Validating environment variables..."
missing_vars=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "ERROR: Missing required environment variables:"
    printf '  - %s\n' "${missing_vars[@]}"
    echo ""
    echo "Please set these variables in Railway dashboard:"
    echo "  Project → Service → Variables"
    exit 1
fi

echo "✓ All required environment variables are set"

# ============================================================================
# Step 2: Generate Configuration from Template
# ============================================================================

echo "Generating homeserver.yaml from template..."

# Set defaults for optional variables
export PGPORT=${PGPORT:-5432}
export SYNAPSE_ENABLE_REGISTRATION=${SYNAPSE_ENABLE_REGISTRATION:-false}
export SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=${SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION:-false}
export SYNAPSE_REPORT_STATS=${SYNAPSE_REPORT_STATS:-false}
export SYNAPSE_PRESENCE_ENABLED=${SYNAPSE_PRESENCE_ENABLED:-true}
export SYNAPSE_PASSWORD_ENABLED=${SYNAPSE_PASSWORD_ENABLED:-false}
export SYNAPSE_LOCALDB_ENABLED=${SYNAPSE_LOCALDB_ENABLED:-false}
export SYNAPSE_ENABLE_METRICS=${SYNAPSE_ENABLE_METRICS:-false}
export SMTP_PORT=${SMTP_PORT:-587}
export EMAIL_ENABLE_NOTIFS=${EMAIL_ENABLE_NOTIFS:-false}

# Generate password pepper if not provided
if [ -z "$SYNAPSE_PASSWORD_PEPPER" ]; then
    echo "Generating password pepper..."
    export SYNAPSE_PASSWORD_PEPPER=$(openssl rand -hex 32)
fi

# Substitute environment variables in template
envsubst < /config/homeserver.yaml.template > /data/homeserver.yaml

echo "✓ Configuration file generated at /data/homeserver.yaml"

# ============================================================================
# Step 3: Handle Signing Key
# ============================================================================

SIGNING_KEY_PATH="/data/signing.key"

if [ -n "$SYNAPSE_SIGNING_KEY" ]; then
    # Use signing key from environment variable
    echo "Using signing key from environment variable..."
    echo "$SYNAPSE_SIGNING_KEY" > "$SIGNING_KEY_PATH"
    chmod 600 "$SIGNING_KEY_PATH"
    echo "✓ Signing key written to $SIGNING_KEY_PATH"
elif [ ! -f "$SIGNING_KEY_PATH" ]; then
    # Generate new signing key
    echo "Generating new signing key..."
    python -m synapse.app.homeserver \
        --server-name="$SYNAPSE_SERVER_NAME" \
        --config-path=/data/homeserver.yaml \
        --generate-keys
    echo "✓ New signing key generated"
    echo ""
    echo "IMPORTANT: Save this signing key to environment variables!"
    echo "Add to Railway variables as SYNAPSE_SIGNING_KEY:"
    echo "----------------------------------------"
    cat "$SIGNING_KEY_PATH"
    echo "----------------------------------------"
else
    echo "✓ Using existing signing key from $SIGNING_KEY_PATH"
fi

# ============================================================================
# Step 4: Database Migrations
# ============================================================================

echo "Running database migrations..."

# Test database connection first
export PGCONNECT_TIMEOUT=10
if ! psql "postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to database"
    echo "Connection string: postgresql://${PGUSER}:****@${PGHOST}:${PGPORT}/${PGDATABASE}"
    echo "Please verify:"
    echo "  1. PostgreSQL plugin is added to Railway project"
    echo "  2. Environment variables are correct"
    echo "  3. Database service is running"
    exit 1
fi

echo "✓ Database connection successful"

# Run Synapse migrations
echo "Applying Synapse schema migrations..."
python -m synapse.app.homeserver \
    --server-name="$SYNAPSE_SERVER_NAME" \
    --config-path=/data/homeserver.yaml \
    --run-background-updates

echo "✓ Database migrations completed"

# ============================================================================
# Step 5: Start Synapse
# ============================================================================

echo "=================================================="
echo "Starting Synapse homeserver..."
echo "Server Name: $SYNAPSE_SERVER_NAME"
echo "Public URL: $SYNAPSE_PUBLIC_BASEURL"
echo "Database: ${PGHOST}:${PGPORT}/${PGDATABASE}"
echo "Registration Enabled: $SYNAPSE_ENABLE_REGISTRATION"
echo "=================================================="

exec python -m synapse.app.homeserver \
    --server-name="$SYNAPSE_SERVER_NAME" \
    --config-path=/data/homeserver.yaml
