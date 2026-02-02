#!/bin/bash
# ============================================================================
# Secret Generation Script for Railway Matrix Deployment
# ============================================================================
# This script generates all required secrets for a Matrix stack deployment.
# Copy the output to your Railway environment variables.
#
# Usage: ./generate_secrets.sh
# ============================================================================

set -e

echo "=================================================="
echo "Matrix Stack Secret Generator"
echo "=================================================="
echo ""
echo "This script will generate all required secrets for your"
echo "Railway Matrix deployment. Keep this output secure!"
echo ""
read -p "Press Enter to continue..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# Generate Secrets
# ============================================================================

echo -e "${GREEN}Generating secrets...${NC}"
echo ""

# Synapse secrets
SYNAPSE_REGISTRATION_SHARED_SECRET=$(openssl rand -hex 32)
SYNAPSE_MACAROON_SECRET_KEY=$(openssl rand -hex 32)
SYNAPSE_FORM_SECRET=$(openssl rand -hex 32)
SYNAPSE_PASSWORD_PEPPER=$(openssl rand -hex 32)
SYNAPSE_ADMIN_TOKEN=$(openssl rand -hex 32)

# MAS secrets
MAS_ENCRYPTION_SECRET=$(openssl rand -hex 64)
MAS_CLIENT_SECRET=$(openssl rand -hex 32)

# Generate EC Private Key for MAS
echo -e "${YELLOW}Generating EC Private Key (MAS signing)...${NC}"
MAS_SIGNING_KEY=$(openssl ecparam -name prime256v1 -genkey -noout 2>/dev/null)

echo ""
echo "=================================================="
echo "✓ Secrets Generated Successfully"
echo "=================================================="
echo ""

# ============================================================================
# Output for Railway Variables
# ============================================================================

cat << EOF
================================================
COPY THESE TO RAILWAY ENVIRONMENT VARIABLES
================================================

---------- SYNAPSE SERVICE ----------

SYNAPSE_REGISTRATION_SHARED_SECRET=$SYNAPSE_REGISTRATION_SHARED_SECRET
SYNAPSE_MACAROON_SECRET_KEY=$SYNAPSE_MACAROON_SECRET_KEY
SYNAPSE_FORM_SECRET=$SYNAPSE_FORM_SECRET
SYNAPSE_PASSWORD_PEPPER=$SYNAPSE_PASSWORD_PEPPER
SYNAPSE_ADMIN_TOKEN=$SYNAPSE_ADMIN_TOKEN

# Database (from Railway PostgreSQL plugin)
PGHOST=postgres.railway.internal
PGPORT=5432
PGUSER=postgres
PGPASSWORD=<FROM_RAILWAY_PLUGIN>
PGDATABASE=railway

# Server Configuration
SYNAPSE_SERVER_NAME=matrix.example.com
SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/

# Optional Settings
SYNAPSE_ENABLE_REGISTRATION=false
SYNAPSE_REPORT_STATS=false
SYNAPSE_PRESENCE_ENABLED=true

---------- MAS SERVICE ----------

MAS_ENCRYPTION_SECRET=$MAS_ENCRYPTION_SECRET
MAS_CLIENT_SECRET=$MAS_CLIENT_SECRET

# IMPORTANT: Must match Synapse registration secret
MAS_MATRIX_SECRET=$SYNAPSE_REGISTRATION_SHARED_SECRET

# EC Private Key (entire key including BEGIN/END lines)
MAS_SIGNING_KEY=$MAS_SIGNING_KEY

# Database (from Railway PostgreSQL plugin - SEPARATE instance)
MAS_PGHOST=postgres-mas.railway.internal
MAS_PGPORT=5432
MAS_PGUSER=postgres
MAS_PGPASSWORD=<FROM_RAILWAY_PLUGIN_2>
MAS_PGDATABASE=railway

# Server Configuration
MAS_PUBLIC_BASE=https://auth.example.com/
MAS_MATRIX_HOMESERVER=matrix.example.com
MAS_MATRIX_ENDPOINT=https://matrix.example.com
MAS_HTTP_PORT=8080

# OAuth Client
MAS_CLIENT_ID=0000000000000000000SYNAPSE

# Optional Settings
MAS_LOG_LEVEL=info
MAS_RATE_LIMITING_ENABLED=true

---------- ELEMENT WEB SERVICE ----------

ELEMENT_HOMESERVER_URL=https://matrix.example.com
ELEMENT_HOMESERVER_NAME=matrix.example.com

# Optional Settings
ELEMENT_BRAND=Element
ELEMENT_DEFAULT_THEME=light
ELEMENT_DISABLE_CUSTOM_URLS=false

================================================
SECURITY REMINDERS
================================================

1. ✓ Generated secrets use cryptographically secure random
2. ⚠️ NEVER commit these secrets to git
3. ⚠️ Store this output in a secure password manager
4. ⚠️ Rotate secrets every 90 days
5. ✓ MAS_MATRIX_SECRET MUST match SYNAPSE_REGISTRATION_SHARED_SECRET
6. ✓ Use separate PostgreSQL instances for Synapse and MAS

================================================
NEXT STEPS
================================================

1. Add PostgreSQL plugins to Railway project (2 instances)
2. Copy database credentials from Railway plugins
3. Replace <FROM_RAILWAY_PLUGIN> with actual values
4. Update domain names (matrix.example.com → your domain)
5. Add all variables to Railway dashboard
6. Deploy services

For detailed setup instructions, see README.md

================================================

EOF

# ============================================================================
# Save to File (Optional)
# ============================================================================

echo ""
read -p "Save secrets to file? (NOT RECOMMENDED for production) [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    OUTPUT_FILE="secrets_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$OUTPUT_FILE" << EOF
# Generated: $(date)
# WARNING: Delete this file after copying to Railway!

SYNAPSE_REGISTRATION_SHARED_SECRET=$SYNAPSE_REGISTRATION_SHARED_SECRET
SYNAPSE_MACAROON_SECRET_KEY=$SYNAPSE_MACAROON_SECRET_KEY
SYNAPSE_FORM_SECRET=$SYNAPSE_FORM_SECRET
SYNAPSE_PASSWORD_PEPPER=$SYNAPSE_PASSWORD_PEPPER
SYNAPSE_ADMIN_TOKEN=$SYNAPSE_ADMIN_TOKEN
MAS_ENCRYPTION_SECRET=$MAS_ENCRYPTION_SECRET
MAS_CLIENT_SECRET=$MAS_CLIENT_SECRET
MAS_MATRIX_SECRET=$SYNAPSE_REGISTRATION_SHARED_SECRET
MAS_SIGNING_KEY=$MAS_SIGNING_KEY
EOF
    
    chmod 600 "$OUTPUT_FILE"
    echo ""
    echo -e "${YELLOW}Secrets saved to: $OUTPUT_FILE${NC}"
    echo -e "${YELLOW}WARNING: Delete this file after copying to Railway!${NC}"
    echo ""
fi

echo "✓ Secret generation complete"
echo ""
