# 📖 Complete Environment Variables Reference

## Overview
This document provides a comprehensive reference for all environment variables used in the Matrix stack Railway deployment. Variables are organized by service with detailed descriptions, valid values, and security recommendations.

---

## 🔴 Synapse Environment Variables

### Required Variables

#### `PGHOST`
- **Description**: PostgreSQL server hostname
- **Example**: `postgres.railway.internal`
- **Source**: Railway PostgreSQL plugin
- **Security**: Low risk (internal hostname)

#### `PGPORT`
- **Description**: PostgreSQL server port
- **Example**: `5432`
- **Default**: `5432`
- **Security**: Low risk

#### `PGUSER`
- **Description**: PostgreSQL username
- **Example**: `postgres`
- **Source**: Railway PostgreSQL plugin
- **Security**: Medium risk (store in Railway variables)

#### `PGPASSWORD`
- **Description**: PostgreSQL password
- **Example**: `eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC`
- **Source**: Railway PostgreSQL plugin
- **Security**: **HIGH RISK** - Never commit to git
- **Rotation**: Every 90 days

#### `PGDATABASE`
- **Description**: PostgreSQL database name
- **Example**: `railway`
- **Source**: Railway PostgreSQL plugin
- **Security**: Low risk

#### `SYNAPSE_SERVER_NAME`
- **Description**: Matrix server domain name (federation identity)
- **Example**: `matrix.example.com`
- **Notes**: Cannot be changed after first user created
- **Security**: Low risk

#### `SYNAPSE_PUBLIC_BASEURL`
- **Description**: Public-facing URL for Synapse
- **Example**: `https://matrix.example.com/`
- **Notes**: Must end with `/`, must be HTTPS
- **Security**: Low risk

#### `SYNAPSE_REGISTRATION_SHARED_SECRET`
- **Description**: Secret for admin user registration
- **Example**: `4578b92c30adf6e1d2b8c5f9a3e7d1b6`
- **Generate**: `openssl rand -hex 32`
- **Length**: 64 characters (hex)
- **Security**: **HIGH RISK** - Used for admin API
- **Rotation**: Every 90 days

#### `SYNAPSE_MACAROON_SECRET_KEY`
- **Description**: Secret for session token generation
- **Example**: `6f01b8a9c5e2d437f9b1c8d2e6f0a3b7`
- **Generate**: `openssl rand -hex 32`
- **Length**: 64 characters (hex)
- **Security**: **HIGH RISK** - Controls user sessions
- **Rotation**: Every 180 days

#### `SYNAPSE_FORM_SECRET`
- **Description**: Secret for CSRF token generation
- **Example**: `32f4cb150ed867a9f2b5c8d1e6f0a3b7`
- **Generate**: `openssl rand -hex 32`
- **Length**: 64 characters (hex)
- **Security**: **HIGH RISK** - CSRF protection
- **Rotation**: Every 180 days

#### `SYNAPSE_SIGNING_KEY`
- **Description**: Ed25519 key for federation signing
- **Example**: `ed25519 a_ZCeH 9G7js4wnPk7YY4mYVzVtlsBG+TOttmlQpybCScj1VL4`
- **Generate**: Run Synapse with `--generate-keys` flag
- **Format**: `ed25519 <key_id> <base64_key>`
- **Security**: **CRITICAL** - Federation identity
- **Rotation**: Every 365 days (requires federation coordination)

### Optional Variables

#### `SYNAPSE_ENABLE_REGISTRATION`
- **Description**: Allow public user registration
- **Values**: `true`, `false`
- **Default**: `false`
- **Production**: `false` (security best practice)

#### `SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION`
- **Description**: Allow registration without email verification
- **Values**: `true`, `false`
- **Default**: `false`
- **Production**: `false`

#### `SYNAPSE_REPORT_STATS`
- **Description**: Send anonymous usage statistics to matrix.org
- **Values**: `true`, `false`
- **Default**: `false`

#### `SYNAPSE_PRESENCE_ENABLED`
- **Description**: Enable user presence (online/offline status)
- **Values**: `true`, `false`
- **Default**: `true`
- **Notes**: Disabling reduces server load

#### `SYNAPSE_PASSWORD_ENABLED`
- **Description**: Enable local password authentication
- **Values**: `true`, `false`
- **Default**: `false` (use MAS for auth)

#### `SYNAPSE_LOCALDB_ENABLED`
- **Description**: Enable local password database
- **Values**: `true`, `false`
- **Default**: `false`

#### `SYNAPSE_PASSWORD_PEPPER`
- **Description**: Additional secret for password hashing
- **Example**: `f9b1c8d2e6f0a3b7c1d5e9f3a7b1c5d9`
- **Generate**: `openssl rand -hex 32`
- **Auto-generated**: If not provided

#### `SYNAPSE_ENABLE_METRICS`
- **Description**: Enable Prometheus metrics endpoint
- **Values**: `true`, `false`
- **Default**: `false`

#### `SYNAPSE_ADMIN_TOKEN`
- **Description**: Bearer token for admin API
- **Example**: `syt_YWRtaW4_aBcDeFgHiJkLmNoPqRsTuV_1234567`
- **Generate**: `openssl rand -hex 32`
- **Security**: **HIGH RISK** - Full admin access

### Email Configuration (Optional)

#### `SMTP_HOST`
- **Description**: SMTP server hostname
- **Example**: `smtp.sendgrid.net`, `smtp.gmail.com`

#### `SMTP_PORT`
- **Description**: SMTP server port
- **Values**: `25`, `587` (STARTTLS), `465` (SSL)
- **Default**: `587`

#### `SMTP_USER`
- **Description**: SMTP authentication username
- **Example**: `apikey` (SendGrid), `your-email@gmail.com`

#### `SMTP_PASS`
- **Description**: SMTP authentication password
- **Example**: `SG.xxxxxxxxxxxxxxxxxxxxxxxx`
- **Security**: **HIGH RISK** - Store in Railway variables

#### `EMAIL_FROM`
- **Description**: Email sender address
- **Example**: `Matrix <noreply@example.com>`

#### `EMAIL_APP_NAME`
- **Description**: Application name in emails
- **Example**: `Matrix`, `MyCompany Chat`

#### `EMAIL_ENABLE_NOTIFS`
- **Description**: Enable email notifications
- **Values**: `true`, `false`
- **Default**: `false`

---

## 🟢 MAS (Matrix Authentication Service) Variables

### Required Variables

#### `MAS_PGHOST`
- **Description**: PostgreSQL server hostname (separate from Synapse)
- **Example**: `postgres-mas.railway.internal`
- **Source**: Railway PostgreSQL plugin (separate instance)
- **Security**: Low risk

#### `MAS_PGPORT`
- **Description**: PostgreSQL server port
- **Example**: `5432`
- **Default**: `5432`

#### `MAS_PGUSER`
- **Description**: PostgreSQL username
- **Example**: `postgres`
- **Source**: Railway PostgreSQL plugin

#### `MAS_PGPASSWORD`
- **Description**: PostgreSQL password
- **Example**: `wHNhQGDToDcZJfzOxEOCjSYnSooDySqt`
- **Security**: **HIGH RISK** - Separate from Synapse DB password
- **Rotation**: Every 90 days

#### `MAS_PGDATABASE`
- **Description**: PostgreSQL database name
- **Example**: `railway`
- **Source**: Railway PostgreSQL plugin

#### `MAS_PUBLIC_BASE`
- **Description**: Public-facing URL for MAS
- **Example**: `https://auth.example.com/`
- **Notes**: Must end with `/`, must be HTTPS

#### `MAS_MATRIX_HOMESERVER`
- **Description**: Matrix server domain (must match Synapse)
- **Example**: `matrix.example.com`
- **Notes**: Must match `SYNAPSE_SERVER_NAME`

#### `MAS_MATRIX_ENDPOINT`
- **Description**: Synapse public URL
- **Example**: `https://matrix.example.com`
- **Notes**: Must match `SYNAPSE_PUBLIC_BASEURL` (without trailing /)

#### `MAS_MATRIX_SECRET`
- **Description**: Shared secret with Synapse
- **Example**: `4578b92c30adf6e1d2b8c5f9a3e7d1b6`
- **Notes**: **MUST MATCH** `SYNAPSE_REGISTRATION_SHARED_SECRET`
- **Security**: **HIGH RISK**

#### `MAS_CLIENT_SECRET`
- **Description**: OAuth client secret for Synapse
- **Example**: `c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7f1`
- **Generate**: `openssl rand -hex 32`
- **Security**: **HIGH RISK**

#### `MAS_ENCRYPTION_SECRET`
- **Description**: Secret for encrypting sensitive data
- **Example**: `c07af15b849e23d6f9a1b4c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7`
- **Generate**: `openssl rand -hex 64`
- **Length**: 128 characters (hex)
- **Security**: **CRITICAL** - Encrypts stored secrets

#### `MAS_SIGNING_KEY`
- **Description**: EC private key for JWT signing (PEM format)
- **Example**:
  ```
  -----BEGIN EC PRIVATE KEY-----
  MHcCAQEEIJGlh975aqLDMRj14FmkOb5BB89gS8q1EdWAqfTQAnozoAoGCCqGSM49
  AwEHoUQDQgAEvJtmvto/lxwcPKke1usYPJuJvp2eVVWeQt1e3/BUvZQuivHR40Sd
  5C6Wdyv0K5s7Z3kLpZ3K8n8lZ7V7Z3kLpZ3K8n8lZ7Vg==
  -----END EC PRIVATE KEY-----
  ```
- **Generate**: `openssl ecparam -name prime256v1 -genkey -noout`
- **Format**: Complete PEM file including BEGIN/END lines
- **Security**: **CRITICAL** - JWT signature verification
- **Notes**: Must be valid PEM format, no NUL bytes

### Optional Variables

#### `MAS_HTTP_PORT`
- **Description**: HTTP listener port
- **Values**: `1-65535`
- **Default**: `8080`

#### `MAS_KEY_ID`
- **Description**: Key identifier for signing key
- **Example**: `default`, `2024-02-key-1`
- **Default**: `default`

#### `MAS_CLIENT_ID`
- **Description**: OAuth client ID for Synapse
- **Example**: `0000000000000000000SYNAPSE`
- **Default**: `0000000000000000000SYNAPSE`
- **Notes**: Must match Synapse configuration

#### `MAS_BRAND_NAME`
- **Description**: Service branding name
- **Example**: `MyCompany Auth`, `Matrix Authentication Service`
- **Default**: `Matrix Authentication Service`

### Email Configuration

#### `MAS_EMAIL_FROM`
- **Description**: Email sender address
- **Example**: `Matrix <noreply@example.com>`
- **Default**: `Matrix <noreply@example.com>`

#### `MAS_EMAIL_REPLY_TO`
- **Description**: Email reply-to address
- **Example**: `Support <support@example.com>`
- **Default**: `Support <support@example.com>`

#### `MAS_SMTP_HOST`
- **Description**: SMTP server hostname
- **Example**: `smtp.sendgrid.net`

#### `MAS_SMTP_PORT`
- **Description**: SMTP server port
- **Values**: `25`, `587`, `465`
- **Default**: `587`

#### `MAS_SMTP_MODE`
- **Description**: SMTP connection mode
- **Values**: `plain`, `starttls`, `tls`
- **Default**: `starttls`

#### `MAS_SMTP_USERNAME`
- **Description**: SMTP authentication username
- **Example**: `apikey`

#### `MAS_SMTP_PASSWORD`
- **Description**: SMTP authentication password
- **Security**: **HIGH RISK**

### Account Management

#### `MAS_PASSWORD_CHANGE_ALLOWED`
- **Description**: Allow users to change passwords
- **Values**: `true`, `false`
- **Default**: `true`

#### `MAS_PASSWORD_REGISTRATION_ENABLED`
- **Description**: Allow password-based registration
- **Values**: `true`, `false`
- **Default**: `true`

#### `MAS_EMAIL_CHANGE_ALLOWED`
- **Description**: Allow users to change email
- **Values**: `true`, `false`
- **Default**: `true`

### Session Configuration

#### `MAS_SESSION_TTL`
- **Description**: Session lifetime in seconds
- **Example**: `3600` (1 hour)
- **Default**: `3600`

#### `MAS_SESSION_IDLE_TTL`
- **Description**: Idle timeout in seconds
- **Example**: `300` (5 minutes)
- **Default**: `300`

### Rate Limiting

#### `MAS_RATE_LIMITING_ENABLED`
- **Description**: Enable rate limiting
- **Values**: `true`, `false`
- **Default**: `true`

#### `MAS_RATE_LIMIT_AUTH_PER_SECOND`
- **Description**: Max auth attempts per second
- **Example**: `0.1` (1 attempt per 10 seconds)
- **Default**: `0.1`

#### `MAS_RATE_LIMIT_AUTH_BURST`
- **Description**: Auth burst allowance
- **Example**: `5`
- **Default**: `5`

#### `MAS_RATE_LIMIT_REGISTRATION_PER_SECOND`
- **Description**: Max registration attempts per second
- **Example**: `0.05` (1 attempt per 20 seconds)
- **Default**: `0.05`

#### `MAS_RATE_LIMIT_REGISTRATION_BURST`
- **Description**: Registration burst allowance
- **Example**: `3`
- **Default**: `3`

### Captcha Configuration

#### `MAS_CAPTCHA_ENABLED`
- **Description**: Enable CAPTCHA for registration/login
- **Values**: `true`, `false`
- **Default**: `false`

#### `RECAPTCHA_SITE_KEY`
- **Description**: Google reCAPTCHA site key
- **Example**: `6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI`
- **Required if**: `MAS_CAPTCHA_ENABLED=true`

#### `RECAPTCHA_SECRET_KEY`
- **Description**: Google reCAPTCHA secret key
- **Security**: **HIGH RISK**
- **Required if**: `MAS_CAPTCHA_ENABLED=true`

### Observability

#### `MAS_TRACING_ENABLED`
- **Description**: Enable distributed tracing
- **Values**: `true`, `false`
- **Default**: `false`

#### `MAS_METRICS_ENABLED`
- **Description**: Enable Prometheus metrics
- **Values**: `true`, `false`
- **Default**: `false`

#### `MAS_LOG_LEVEL`
- **Description**: Logging verbosity
- **Values**: `trace`, `debug`, `info`, `warn`, `error`
- **Default**: `info`

#### `MAS_LOG_FORMAT`
- **Description**: Log output format
- **Values**: `json`, `pretty`, `compact`
- **Default**: `json`

---

## 🔵 Element Web Variables

### Required Variables

#### `ELEMENT_HOMESERVER_URL`
- **Description**: Synapse public URL
- **Example**: `https://matrix.example.com`
- **Notes**: Must match Synapse deployment

#### `ELEMENT_HOMESERVER_NAME`
- **Description**: Matrix server domain
- **Example**: `matrix.example.com`
- **Notes**: Must match `SYNAPSE_SERVER_NAME`

### Optional Variables

#### `ELEMENT_BRAND`
- **Description**: Application branding name
- **Example**: `Element`, `MyCompany Chat`
- **Default**: `Element`

#### `ELEMENT_DEFAULT_COUNTRY_CODE`
- **Description**: Default country code for phone numbers
- **Example**: `US`, `GB`, `FR`
- **Default**: `US`

#### `ELEMENT_SHOW_LABS_SETTINGS`
- **Description**: Show experimental features
- **Values**: `true`, `false`
- **Default**: `false`

#### `ELEMENT_DEFAULT_THEME`
- **Description**: Default UI theme
- **Values**: `light`, `dark`
- **Default**: `light`

#### `ELEMENT_ENABLE_PRESENCE`
- **Description**: Show user online/offline status
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_DISABLE_CUSTOM_URLS`
- **Description**: Prevent custom homeserver URL
- **Values**: `true`, `false`
- **Default**: `false`

#### `ELEMENT_DISABLE_GUESTS`
- **Description**: Disable guest access
- **Values**: `true`, `false`
- **Default**: `false`

#### `ELEMENT_DISABLE_LANGUAGE_SELECTOR`
- **Description**: Hide language selector
- **Values**: `true`, `false`
- **Default**: `false`

#### `ELEMENT_DISABLE_3PID_LOGIN`
- **Description**: Disable email/phone login
- **Values**: `true`, `false`
- **Default**: `false`

#### `ELEMENT_DEFAULT_FEDERATE`
- **Description**: Default federation setting for new rooms
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_PERMALINK_PREFIX`
- **Description**: URL prefix for room/user links
- **Example**: `https://matrix.to`
- **Default**: `https://matrix.to`

#### `ELEMENT_JITSI_DOMAIN`
- **Description**: Jitsi server for video calls
- **Example**: `meet.element.io`, `jitsi.example.com`
- **Default**: `meet.element.io`

#### `ELEMENT_CALL_URL`
- **Description**: Element Call instance URL
- **Example**: `https://call.element.io`

#### `ELEMENT_CALL_PARTICIPANT_LIMIT`
- **Description**: Max participants in Element Call
- **Example**: `8`
- **Default**: `8`

### UI Features

#### `ELEMENT_FEATURE_FEEDBACK`
- **Description**: Enable feedback/bug reporting
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_FEATURE_VOIP`
- **Description**: Enable voice/video calls
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_FEATURE_WIDGETS`
- **Description**: Enable room widgets/integrations
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_FEATURE_FLAIR`
- **Description**: Enable community flair
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_FEATURE_COMMUNITIES`
- **Description**: Enable communities (deprecated)
- **Values**: `true`, `false`
- **Default**: `false`

#### `ELEMENT_FEATURE_ADVANCED`
- **Description**: Enable advanced settings
- **Values**: `true`, `false`
- **Default**: `true`

#### `ELEMENT_FEATURE_CUSTOM_THEMES`
- **Description**: Enable custom themes
- **Values**: `true`, `false`
- **Default**: `true`

### Optional URLs

#### `ELEMENT_BUG_REPORT_URL`
- **Description**: Bug report endpoint
- **Example**: `https://bugs.example.com/submit`

#### `ELEMENT_TERMS_URL`
- **Description**: Terms of service URL
- **Example**: `https://example.com/terms`

#### `ELEMENT_PRIVACY_URL`
- **Description**: Privacy policy URL
- **Example**: `https://example.com/privacy`

---

## 📝 Variable Setup Examples

### Railway Dashboard Setup

```bash
# 1. Navigate to Railway project
# 2. Select service (Synapse, MAS, or Element Web)
# 3. Click "Variables" tab
# 4. Click "New Variable"

# Example: Adding Synapse macaroon secret
Name: SYNAPSE_MACAROON_SECRET_KEY
Value: 6f01b8a9c5e2d437f9b1c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7

# Click "Add" and service will auto-restart
```

### Bulk Import (Railway CLI)

```bash
# Create .env.railway file (DO NOT COMMIT!)
cat > .env.railway << 'EOF'
PGHOST=postgres.railway.internal
PGUSER=postgres
PGPASSWORD=your_db_password_here
SYNAPSE_SERVER_NAME=matrix.example.com
SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/
# ... more variables
EOF

# Import to Railway
railway variables --set-all < .env.railway

# Delete local file immediately
rm .env.railway
```

---

## 🔍 Variable Validation

### Pre-Deployment Checklist

```bash
# Check for required variables
required_vars=(
    "PGHOST" "PGUSER" "PGPASSWORD"
    "SYNAPSE_SERVER_NAME" "SYNAPSE_PUBLIC_BASEURL"
    "SYNAPSE_REGISTRATION_SHARED_SECRET"
    "MAS_PUBLIC_BASE" "MAS_ENCRYPTION_SECRET"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Missing: $var"
    fi
done
```

### Secret Strength Validation

```bash
# Check secret length
secret="your_secret_here"
length=${#secret}

if [ $length -lt 32 ]; then
    echo "WARNING: Secret too short ($length chars, minimum 32)"
fi

# Check for randomness (basic)
if echo "$secret" | grep -qE "^[a-z]+$|^[0-9]+$|password|secret"; then
    echo "WARNING: Secret may not be random enough"
fi
```

---

**For deployment instructions, see [README.md](../README.md)**
