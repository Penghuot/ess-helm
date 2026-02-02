#!/bin/bash
# ============================================================================
# Element Web Entrypoint Script
# ============================================================================
# This script:
# 1. Validates required environment variables
# 2. Generates config.json from template
# 3. Starts nginx server
# ============================================================================

set -e

echo "=================================================="
echo "Element Web Railway Deployment - Starting"
echo "=================================================="

# ============================================================================
# Step 1: Validate Required Environment Variables
# ============================================================================

REQUIRED_VARS=(
    "ELEMENT_HOMESERVER_URL"
    "ELEMENT_HOMESERVER_NAME"
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
    exit 1
fi

echo "✓ All required environment variables are set"

# ============================================================================
# Step 2: Set Default Values for Optional Variables
# ============================================================================

export ELEMENT_BRAND=${ELEMENT_BRAND:-Element}
export ELEMENT_DEFAULT_COUNTRY_CODE=${ELEMENT_DEFAULT_COUNTRY_CODE:-US}
export ELEMENT_SHOW_LABS_SETTINGS=${ELEMENT_SHOW_LABS_SETTINGS:-false}
export ELEMENT_DEFAULT_THEME=${ELEMENT_DEFAULT_THEME:-light}
export ELEMENT_ENABLE_PRESENCE=${ELEMENT_ENABLE_PRESENCE:-true}
export ELEMENT_DISABLE_CUSTOM_URLS=${ELEMENT_DISABLE_CUSTOM_URLS:-false}
export ELEMENT_DISABLE_GUESTS=${ELEMENT_DISABLE_GUESTS:-false}
export ELEMENT_DISABLE_LANGUAGE_SELECTOR=${ELEMENT_DISABLE_LANGUAGE_SELECTOR:-false}
export ELEMENT_DISABLE_3PID_LOGIN=${ELEMENT_DISABLE_3PID_LOGIN:-false}
export ELEMENT_DEFAULT_FEDERATE=${ELEMENT_DEFAULT_FEDERATE:-true}
export ELEMENT_PERMALINK_PREFIX=${ELEMENT_PERMALINK_PREFIX:-https://matrix.to}
export ELEMENT_JITSI_DOMAIN=${ELEMENT_JITSI_DOMAIN:-meet.element.io}
export ELEMENT_CALL_PARTICIPANT_LIMIT=${ELEMENT_CALL_PARTICIPANT_LIMIT:-8}
export ELEMENT_FEATURE_FEEDBACK=${ELEMENT_FEATURE_FEEDBACK:-true}
export ELEMENT_FEATURE_VOIP=${ELEMENT_FEATURE_VOIP:-true}
export ELEMENT_FEATURE_WIDGETS=${ELEMENT_FEATURE_WIDGETS:-true}
export ELEMENT_FEATURE_FLAIR=${ELEMENT_FEATURE_FLAIR:-true}
export ELEMENT_FEATURE_COMMUNITIES=${ELEMENT_FEATURE_COMMUNITIES:-false}
export ELEMENT_FEATURE_ADVANCED=${ELEMENT_FEATURE_ADVANCED:-true}
export ELEMENT_FEATURE_CUSTOM_THEMES=${ELEMENT_FEATURE_CUSTOM_THEMES:-true}

# ============================================================================
# Step 3: Generate Configuration from Template
# ============================================================================

echo "Generating config.json from template..."

# Substitute environment variables in template
envsubst < /app/config.json.template > /app/config.json

echo "✓ Configuration file generated at /app/config.json"

# Validate JSON syntax
if ! python3 -c "import json; json.load(open('/app/config.json'))" 2>/dev/null; then
    echo "ERROR: Generated config.json has invalid JSON syntax"
    echo "Check the template and environment variables"
    exit 1
fi

echo "✓ JSON syntax is valid"

# ============================================================================
# Step 4: Display Configuration Summary
# ============================================================================

echo "=================================================="
echo "Configuration Summary:"
echo "=================================================="
echo "Homeserver URL: $ELEMENT_HOMESERVER_URL"
echo "Server Name: $ELEMENT_HOMESERVER_NAME"
echo "Brand: $ELEMENT_BRAND"
echo "Default Theme: $ELEMENT_DEFAULT_THEME"
echo "Disable Custom URLs: $ELEMENT_DISABLE_CUSTOM_URLS"
echo "=================================================="

# ============================================================================
# Step 5: Start nginx
# ============================================================================

echo "Starting nginx web server..."

# Start nginx in foreground
exec nginx -g 'daemon off;'
