#!/bin/bash
# ============================================================================
# MAS (Matrix Authentication Service) Entrypoint Script
# ============================================================================
# This script:
# 1. Validates required environment variables
# 2. Generates configuration from template
# 3. Validates PEM key format
# 4. Runs database migrations
# 5. Starts MAS server
# ============================================================================

set -e

echo "=================================================="
echo "MAS Railway Deployment - Starting"
echo "=================================================="

# ============================================================================
# Step 1: Validate Required Environment Variables
# ============================================================================

REQUIRED_VARS=(
    "MAS_PGHOST"
    "MAS_PGUSER"
    "MAS_PGPASSWORD"
    "MAS_PGDATABASE"
    "MAS_PUBLIC_BASE"
    "MAS_MATRIX_HOMESERVER"
    "MAS_MATRIX_ENDPOINT"
    "MAS_MATRIX_SECRET"
    "MAS_CLIENT_SECRET"
    "MAS_ENCRYPTION_SECRET"
    "MAS_SIGNING_KEY"
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
    echo "Please set these variables in Railway dashboard."
    echo ""
    echo "To generate secrets, run:"
    echo "  openssl rand -hex 32   # For 64-char secrets"
    echo "  openssl rand -hex 64   # For 128-char encryption secret"
    echo "  openssl ecparam -name prime256v1 -genkey -noout  # For signing key"
    exit 1
fi

echo "✓ All required environment variables are set"

# ============================================================================
# Step 2: Validate PEM Key Format
# ============================================================================

echo "Validating PEM key format..."

# Check if signing key starts with proper PEM header
if ! echo "$MAS_SIGNING_KEY" | grep -q "BEGIN EC PRIVATE KEY"; then
    echo "ERROR: MAS_SIGNING_KEY must be a valid PEM-formatted EC private key"
    echo ""
    echo "Generate a valid key with:"
    echo "  openssl ecparam -name prime256v1 -genkey -noout"
    echo ""
    echo "The key should look like:"
    echo "-----BEGIN EC PRIVATE KEY-----"
    echo "MHcCAQEEI..."
    echo "-----END EC PRIVATE KEY-----"
    echo ""
    echo "Store the ENTIRE key (including BEGIN/END lines) in MAS_SIGNING_KEY"
    exit 1
fi

# Check for NUL bytes or invalid characters
if echo "$MAS_SIGNING_KEY" | grep -q $'\x00'; then
    echo "ERROR: MAS_SIGNING_KEY contains NUL bytes"
    echo "This usually means environment variable substitution failed."
    echo "Make sure you're not using placeholders like \${VAR} in the actual key."
    exit 1
fi

echo "✓ PEM key format is valid"

# ============================================================================
# Step 3: Set Default Values for Optional Variables
# ============================================================================

export MAS_HTTP_PORT=${MAS_HTTP_PORT:-8080}
export MAS_PGPORT=${MAS_PGPORT:-5432}
export MAS_KEY_ID=${MAS_KEY_ID:-default}
export MAS_CLIENT_ID=${MAS_CLIENT_ID:-0000000000000000000SYNAPSE}
export MAS_SMTP_PORT=${MAS_SMTP_PORT:-587}
export MAS_SMTP_MODE=${MAS_SMTP_MODE:-starttls}
export MAS_PASSWORD_CHANGE_ALLOWED=${MAS_PASSWORD_CHANGE_ALLOWED:-true}
export MAS_PASSWORD_REGISTRATION_ENABLED=${MAS_PASSWORD_REGISTRATION_ENABLED:-true}
export MAS_EMAIL_CHANGE_ALLOWED=${MAS_EMAIL_CHANGE_ALLOWED:-true}
export MAS_SESSION_TTL=${MAS_SESSION_TTL:-3600}
export MAS_SESSION_IDLE_TTL=${MAS_SESSION_IDLE_TTL:-300}
export MAS_RATE_LIMITING_ENABLED=${MAS_RATE_LIMITING_ENABLED:-true}
export MAS_RATE_LIMIT_AUTH_PER_SECOND=${MAS_RATE_LIMIT_AUTH_PER_SECOND:-0.1}
export MAS_RATE_LIMIT_AUTH_BURST=${MAS_RATE_LIMIT_AUTH_BURST:-5}
export MAS_RATE_LIMIT_REGISTRATION_PER_SECOND=${MAS_RATE_LIMIT_REGISTRATION_PER_SECOND:-0.05}
export MAS_RATE_LIMIT_REGISTRATION_BURST=${MAS_RATE_LIMIT_REGISTRATION_BURST:-3}
export MAS_CAPTCHA_ENABLED=${MAS_CAPTCHA_ENABLED:-false}
export MAS_TRACING_ENABLED=${MAS_TRACING_ENABLED:-false}
export MAS_METRICS_ENABLED=${MAS_METRICS_ENABLED:-false}
export MAS_LOG_LEVEL=${MAS_LOG_LEVEL:-info}
export MAS_LOG_FORMAT=${MAS_LOG_FORMAT:-json}
export MAS_BRAND_NAME=${MAS_BRAND_NAME:-Matrix Authentication Service}

# ============================================================================
# Step 4: Generate Configuration from Template
# ============================================================================

echo "Generating config.yaml from template..."

# Properly format the PEM key with indentation for YAML
# The private_key field needs proper indentation (8 spaces for content)
export MAS_SIGNING_KEY_INDENTED=$(echo "$MAS_SIGNING_KEY" | sed 's/^/        /')

# Create config file
envsubst < /config/config.yaml.template > /config/config.yaml

echo "✓ Configuration file generated at /config/config.yaml"

# Validate YAML syntax
if ! python3 -c "import yaml; yaml.safe_load(open('/config/config.yaml'))" 2>/dev/null; then
    echo "ERROR: Generated config.yaml has invalid YAML syntax"
    echo "Check the template and environment variables"
    exit 1
fi

echo "✓ YAML syntax is valid"

# ============================================================================
# Step 5: Test Database Connection
# ============================================================================

echo "Testing database connection..."

export PGCONNECT_TIMEOUT=10
DB_URI="postgresql://${MAS_PGUSER}:${MAS_PGPASSWORD}@${MAS_PGHOST}:${MAS_PGPORT}/${MAS_PGDATABASE}"

if ! psql "$DB_URI" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to database"
    echo "Connection: ${MAS_PGHOST}:${MAS_PGPORT}/${MAS_PGDATABASE}"
    echo ""
    echo "Please verify:"
    echo "  1. PostgreSQL plugin is added (separate from Synapse DB)"
    echo "  2. MAS_PGHOST, MAS_PGUSER, MAS_PGPASSWORD are correct"
    echo "  3. Database service is running"
    exit 1
fi

echo "✓ Database connection successful"

# ============================================================================
# Step 6: Run Database Migrations
# ============================================================================

echo "Running database migrations..."

# MAS automatically runs migrations on startup, but we can check table existence
TABLES=$(psql "$DB_URI" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';")

if [ "$TABLES" -eq "0" ]; then
    echo "Database is empty, migrations will run on first start"
else
    echo "✓ Database already initialized with $TABLES tables"
fi

# ============================================================================
# Step 7: Display Configuration Summary
# ============================================================================

echo "=================================================="
echo "Configuration Summary:"
echo "=================================================="
echo "Public Base URL: $MAS_PUBLIC_BASE"
echo "Matrix Homeserver: $MAS_MATRIX_HOMESERVER"
echo "Matrix Endpoint: $MAS_MATRIX_ENDPOINT"
echo "Database: ${MAS_PGHOST}:${MAS_PGPORT}/${MAS_PGDATABASE}"
echo "HTTP Port: $MAS_HTTP_PORT"
echo "Client ID: $MAS_CLIENT_ID"
echo "Log Level: $MAS_LOG_LEVEL"
echo "Rate Limiting: $MAS_RATE_LIMITING_ENABLED"
echo "=================================================="

# ============================================================================
# Step 8: Start MAS Server
# ============================================================================

echo "Starting MAS server..."

# Set config path for MAS
export MAS_CONFIG_PATH=/config/config.yaml

# Start MAS based on command
case "$1" in
    "server")
        exec mas-server
        ;;
    "migrate")
        exec mas-cli database migrate
        ;;
    "manage")
        shift
        exec mas-cli manage "$@"
        ;;
    *)
        echo "Usage: entrypoint.sh [server|migrate|manage]"
        exit 1
        ;;
esac
