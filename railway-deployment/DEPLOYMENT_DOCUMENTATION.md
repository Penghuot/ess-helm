# Railway Deployment Guide: Matrix Synapse + MAS + Element Web

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Detailed Configuration](#detailed-configuration)
5. [Deployment Process](#deployment-process)
6. [Verification & Testing](#verification--testing)
7. [User Management](#user-management)
8. [Troubleshooting](#troubleshooting)
9. [Next Steps](#next-steps)

---

## Overview

This document covers the complete deployment of a Matrix communication stack on Railway.app, consisting of:

- **Synapse**: Matrix homeserver for federated communication
- **MAS (Matrix Authentication Service)**: Modern OIDC-based user authentication
- **Element Web**: Web-based Matrix client
- **PostgreSQL**: Two separate databases for Synapse and MAS

### What is Matrix?

Matrix is an open standard for real-time communication that enables:
- Decentralized messaging between servers
- Interoperability with other Matrix servers (federation)
- Strong encryption and user privacy
- REST API for custom integrations

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Railway.app Platform                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Load Balancer (Railway)                  │  │
│  └──────────────────────────────────────────────────────┘  │
│       │                    │                    │            │
│       ▼                    ▼                    ▼            │
│  ┌──────────┐         ┌──────────┐        ┌──────────┐    │
│  │ Synapse  │         │   MAS    │        │ Element  │    │
│  │ :8008    │         │  :8080   │        │   Web    │    │
│  │          │         │          │        │   :80    │    │
│  └──────┬───┘         └────┬─────┘        └────┬─────┘    │
│         │                  │                    │           │
│         └──────────────────┼────────────────────┘           │
│                            │                                 │
│         ┌──────────────────┴──────────────────┐            │
│         ▼                                      ▼            │
│    ┌─────────────────┐          ┌─────────────────────┐   │
│    │ PostgreSQL DB   │          │ PostgreSQL DB       │   │
│    │ (Synapse)       │          │ (MAS)               │   │
│    │ port: 5432      │          │ port: 5432          │   │
│    └─────────────────┘          └─────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘

User Connection Flow:
Element Web (Browser) 
  ↓ (HTTPS)
  └→ Synapse Server ←→ MAS (authentication)
       ↓
       PostgreSQL
```

### Service Details

| Service | Port | Purpose | Technology |
|---------|------|---------|-----------|
| **Synapse** | 8008 | Matrix homeserver, handles federation & clients | Python (matrixdotorg/synapse) |
| **MAS** | 8080 | User authentication & account management | Rust (matrix-org/mas) |
| **Element Web** | 80 | Web client UI | Vue.js (vectorim/element-web) |
| **Synapse DB** | 5432 | Stores all messages, users, rooms | PostgreSQL |
| **MAS DB** | 5432 | Stores user accounts, authentication data | PostgreSQL |

---

## Prerequisites

### Required
- Railway.app account with billing enabled
- Git repository access
- Domain name (or use Railway's auto-generated domain)
- Basic familiarity with YAML configuration

### What You'll Need
- Server name: `synapse-production-e979.up.railway.app`
- Two PostgreSQL databases (one for Synapse, one for MAS)
- Generated secrets (registration keys, encryption keys, signing keys)

---

## Detailed Configuration

### 1. Synapse Configuration

**File**: `railway-deployment/synapse/homeserver.yaml`

#### Key Settings Explained

```yaml
server_name: "synapse-production-e979.up.railway.app"
```
- **Purpose**: Unique identifier for your Matrix server
- **Immutable**: Cannot change this after users join
- **Format**: Should match your domain name

```yaml
public_baseurl: "https://synapse-production-e979.up.railway.app/"
```
- **Purpose**: External URL clients use to reach Synapse
- **Must be HTTPS**: Required for federation and security
- **Used by**: Clients for avatar/media URLs

```yaml
listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    bind_addresses: ["0.0.0.0"]
```
- **Port 8008**: Synapse listens on this port inside container
- **tls: false**: Railway handles HTTPS at load balancer level
- **x_forwarded: true**: Trusts X-Forwarded-For headers from Railway
- **0.0.0.0**: Listens on all network interfaces

#### Database Configuration

```yaml
database:
  name: psycopg2
  args:
    user: postgres
    password: eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC
    host: postgres.railway.internal
    port: 5432
    database: railway
    cp_min: 5
    cp_max: 10
  allow_unsafe_locale: true
```

- **Host**: `postgres.railway.internal` = Railway's internal DNS for PostgreSQL
- **Connection pool**: cp_min=5, cp_max=10 (minimum/maximum connections)
- **allow_unsafe_locale**: Allows UTF-8 locale (required on Railway)
- **Important**: These are hardcoded for testing; use environment variables in production

#### Security Secrets

```yaml
registration_shared_secret: "4578b92c30adf6e1"
macaroon_secret_key: "6f01b8a9c5e2d437"
form_secret: "32f4cb150ed867a9"
```

- **registration_shared_secret**: Used for admin API to create users
- **macaroon_secret_key**: Encrypts session tokens
- **form_secret**: CSRF protection for login forms
- **Generate new secrets**: Use `python -c "import secrets; print(secrets.token_hex(8))"`

#### User Registration

```yaml
enable_registration: true
enable_registration_without_verification: true
```

- **enable_registration**: Allow new users to sign up
- **without_verification**: Skip email verification (not recommended for production)
- **Disable after setup**: Change to `false` after creating admin account

#### Signing Key

```yaml
signing_key_path: "/data/synapse-production-e979.up.railway.app.signing.key"
```

- **Purpose**: Signs federation messages so other servers trust them
- **Format**: Ed25519 key generated by Synapse
- **Content**: `ed25519 <key_id> <base64_key>`
- **Cannot change**: Changing invalidates federation

### 2. MAS (Matrix Authentication Service) Configuration

**File**: `railway-deployment/MAS-service/config.yaml`

#### HTTP Configuration

```yaml
http:
  public_base: "https://mas-service-production.up.railway.app/"
  listeners:
    - name: web
      binds:
        - address: "0.0.0.0:8080"
      proxy_protocol: false
      resources:
        - name: discovery
        - name: human
        - name: oauth
        - name: compat
        - name: graphql
        - name: assets
```

- **public_base**: External URL (HTTPS only)
- **0.0.0.0:8080**: Bind to all interfaces on port 8080
- **Resources**: APIs that MAS exposes:
  - `discovery`: OIDC discovery endpoint
  - `human`: User-facing web UI
  - `oauth`: OAuth 2.0 authorization server
  - `compat`: Compatibility layer with legacy servers
  - `graphql`: GraphQL API for admin/advanced users
  - `assets`: Static assets (CSS, JS, etc.)

#### Database Connection

```yaml
database:
  uri: "postgresql://postgres:wHNhQGDToDcZJfzOxEOCjSYnSooDySqt@postgres-h2zw.railway.internal:5432/railway"
```

- **Separate database**: Uses different PostgreSQL instance than Synapse
- **URI format**: `postgresql://user:password@host:port/database`
- **Must use PostgreSQL**: Not compatible with SQLite

#### Matrix Server Configuration

```yaml
matrix:
  homeserver: "synapse-production-e979.up.railway.app"
  endpoint: "https://synapse-production-e979.up.railway.app"
  secret: "4578b92c30adf6e1"
```

- **homeserver**: Server name (matches Synapse server_name)
- **endpoint**: URL to reach Synapse (HTTPS, internal can use hostname)
- **secret**: Shared secret between Synapse and MAS (registration_shared_secret)

#### Synapse Integration

```yaml
clients:
  - client_id: "0000000000000000000SYNAPSE"
    client_auth_method: "client_secret_basic"
    client_secret: "4578b92c30adf6e1"
```

- **client_id**: OAuth client identifier (hardcoded for Synapse integration)
- **client_secret**: Must match `matrix.secret` value
- **client_auth_method**: How Synapse authenticates to MAS

#### Cryptographic Keys

```yaml
secrets:
  encryption: "c07af15b849e23d6f9a1b4c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7"
  keys:
    - kid: "default"
      private_key: |
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIJGlh975aqLDMRj14FmkOb5BB89gS8q1EdWAqfTQAnozoAoGCCqGSM49
        AwEHoUQDQgAEvJtmvto/lxwcPKke1usYPJuJvp2eVVWeQt1e3/BUvZQuivHR40Sd
        5C6Wdyv0K5s7Z3kLpZ3K8n8lZ7V7Z3kLpZ3K8n8lZ7Vg==
        -----END EC PRIVATE KEY-----
```

- **encryption**: 64-character hex string for encrypting sensitive data
- **private_key**: EC (Elliptic Curve) private key in PEM format
- **kid**: Key identifier ("default" = use this key by default)
- **IMPORTANT**: Must be valid EC private key, not RSA or other formats

**Common Error**: "PEM preamble contains invalid data" = key contains NUL bytes or is malformed

#### Password Schemes

```yaml
passwords:
  enabled: true
  schemes:
    - version: 1
      algorithm: argon2id
```

- **enabled**: Allow username/password login
- **argon2id**: Modern, secure password hashing algorithm
- **version**: Configuration version for the scheme

#### Email Configuration

```yaml
email:
  from: '"Matrix" <noreply@synapse-production-e979.up.railway.app>'
  reply_to: '"Matrix Support" <support@synapse-production-e979.up.railway.app>'
  transport: blackhole
```

- **from**: Display name and email for emails sent by MAS
- **reply_to**: Where users send support emails
- **transport: blackhole**: Discard emails (use `smtp` for production)

### 3. Element Web Configuration

**File**: `railway-deployment/element-web/config.json`

```json
{
  "default_server_config": {
    "m.homeserver": {
      "base_url": "https://synapse-production-e979.up.railway.app",
      "server_name": "synapse-production-e979.up.railway.app"
    }
  },
  "disable_custom_urls": false,
  "disable_guests": false,
  "brand": "Element",
  "default_country_code": "US",
  "show_labs_settings": true,
  "default_theme": "light",
  "room_directory": {
    "servers": ["matrix.org", "synapse-production-e979.up.railway.app"]
  }
}
```

- **m.homeserver.base_url**: URL where Synapse is accessible
- **server_name**: Matrix server name
- **disable_custom_urls**: If true, prevents users from changing server
- **disable_guests**: If true, requires login to browse
- **brand**: App branding name
- **room_directory**: Which servers to show in room discovery

### 4. Docker Configuration

#### Synapse Dockerfile

```dockerfile
FROM matrixdotorg/synapse:latest

USER root

# Create media store directory
RUN mkdir -p /data/media_store

# Copy configs
COPY homeserver.yaml /data/homeserver.yaml
COPY synapse-config/synapse-production-e979.up.railway.app.signing.key /data/synapse-production-e979.up.railway.app.signing.key
COPY synapse-config/synapse-production-e979.up.railway.app.log.config /data/synapse-production-e979.up.railway.app.log.config

# Set permissions
RUN chown -R 991:991 /data && chmod -R 755 /data

USER 991

EXPOSE 8008
```

**Key Points**:
- Uses official `matrixdotorg/synapse:latest` image
- Creates `/data/media_store` for storing user media/avatars
- Copies configuration files into the container
- Sets proper permissions (991:991 = synapse user/group)
- Runs as non-root user (security best practice)
- Exposes port 8008 for HTTP listener

#### MAS Dockerfile

```dockerfile
FROM ghcr.io/matrix-org/matrix-authentication-service:latest

# Copy configuration
COPY config.yaml /config.yaml

# Set config path for runtime
ENV MAS_CONFIG_PATH=/config.yaml

# Expose port
EXPOSE 8080

# Don't run any validation at build time, let the service handle it at runtime
```

**Key Points**:
- Uses official MAS Docker image
- Copies config to `/config.yaml`
- Sets environment variable for config location
- Exposes port 8080

#### Element Web Dockerfile

```dockerfile
FROM vectorim/element-web:latest

COPY config.json /app/config.json

EXPOSE 80
```

**Key Points**:
- Uses official Element Web image with nginx pre-configured
- Copies config.json (overrides default)
- Exposes port 80 (nginx handles HTTP)
- No custom entrypoint needed - base image handles it

---

## Deployment Process

### Step 1: Prepare Repository Structure

```
railway-deployment/
├── synapse/
│   ├── Dockerfile
│   ├── homeserver.yaml
│   ├── railway.json
│   └── synapse-config/
│       ├── synapse-production-e979.up.railway.app.signing.key
│       └── synapse-production-e979.up.railway.app.log.config
├── MAS-service/
│   ├── Dockerfile
│   ├── config.yaml
│   └── railway.json
└── element-web/
    ├── Dockerfile
    ├── config.json
    └── railway.json
```

### Step 2: Generate Required Files

#### Signing Key (Synapse)

Generated using Synapse:
```
ed25519 a_ZCeH 9G7js4wnPk7YY4mYVzVtlsBG+TOttmlQpybCScj1VL4
```

**Format**: `ed25519 <key_id> <base64_key>`

#### Log Configuration

Standard Python logging format, provided in `synapse-config/`

### Step 3: Create Railway Services

In Railway dashboard:
1. Create new project
2. Add PostgreSQL (create 2 instances)
3. Add 3 custom services (Synapse, MAS, Element Web)

**For each service**:
- Set build command: (Railway auto-detects from Dockerfile)
- Set start command: (Railway auto-starts from image)
- Configure ports in Settings
- Link to appropriate database

### Step 4: Configure Environment

Railway creates internal DNS automatically:
- `postgres.railway.internal` (Synapse DB)
- `postgres-h2zw.railway.internal` (MAS DB)

**Get credentials from Railway UI**:
- Database password
- Internal hostname
- Port (always 5432)

### Step 5: Deploy

1. Commit all changes to `railway-deployment` branch
2. Push to repository
3. Railway automatically builds images from Dockerfile
4. Services start in order
5. Wait 2-3 minutes for initialization

**Check Logs**:
- Railway UI → Service → Logs tab
- Look for "server started successfully"

---

## Verification & Testing

### 1. Test Synapse Health

```bash
# Test HTTP endpoint (health check)
curl https://synapse-production-e979.up.railway.app/_matrix/static/

# Test client versions API
curl https://synapse-production-e979.up.railway.app/_matrix/client/versions

# Expected response:
{
  "versions": ["r0.0.1", "r0.1.0", ..., "v1.13"]
}
```

### 2. Test MAS Health

```bash
curl https://mas-service-production.up.railway.app/health

# Expected response:
{
  "status": "ok",
  ...
}
```

### 3. Test Element Web

Open in browser:
```
https://ess-helm-production.up.railway.app/#/login
```

**Expected**: Login page loads, can connect to Synapse

### 4. Test User Login Flow

1. Click "Create account" on login page
2. Enter username and password
3. Should redirect to MAS for authentication
4. After login, should see Element Web interface
5. Should be able to create rooms and send messages

### 5. Federation Test

Use Matrix Federation Tester:
```
https://federationtester.matrix.org/
```

Enter: `synapse-production-e979.up.railway.app`

**Expected results**:
- ✓ Server is discoverable
- ✓ Well-known delegation works
- ✓ Federation keys valid
- ✓ Can send test message

---

## User Management

### Create First Admin User

Via Element Web (Registration):
1. Open login page
2. Click "Create account"
3. Choose username and password
4. Complete registration

Via MAS CLI (Recommended for first user):

```bash
# SSH into MAS container on Railway
cd /usr/local/bin

# Run user registration
./mas-cli manage register-user

# Follow prompts:
# - Username: alice
# - Password: (secure password)
# - Make admin: yes
```

### Grant Admin Privileges

```bash
# Connect to Synapse PostgreSQL
psql -h postgres.railway.internal -U postgres -d railway

# Grant admin:
UPDATE users SET admin = 1 WHERE name = '@alice:synapse-production-e979.up.railway.app';
```

### Manage Users in MAS

**Via web UI**:
- Go to `https://mas-service-production.up.railway.app/admin`
- Login with admin credentials
- Create/edit/delete users

**Via CLI**:
```bash
# List users
mas-cli manage list-users

# Reset password
mas-cli manage password reset <username>
```

---

## Troubleshooting

### Synapse Returns 502 Bad Gateway

**Causes**:
1. Database connectivity issue
2. Configuration parsing error
3. Permission denied on `/data/media_store`
4. Signing key invalid format

**Solutions**:
1. Check Railway logs: Settings → Logs
2. Verify database credentials in `homeserver.yaml`
3. Check PostgreSQL is running: Railway dashboard
4. Verify signing key exists and is valid

```bash
# Check key format (should be single line starting with "ed25519"):
grep "ed25519" synapse-production-e979.up.railway.app.signing.key
```

### MAS Fails to Start: "missing field `secrets`"

**Cause**: Invalid PEM key format (contains NUL bytes)

**Solution**: Generate valid EC private key

```bash
# Generate new EC key:
openssl ecparam -name prime256v1 -genkey -out private.pem
cat private.pem | sed 's/^/        /'  # indent for YAML

# Update config.yaml with the output
```

### Element Web Shows "Cannot reach homeserver"

**Causes**:
1. Element Web config points to wrong Synapse URL
2. Synapse returning error
3. CORS issues
4. SSL certificate untrusted

**Solutions**:
1. Verify `config.json` has correct `base_url`
2. Test Synapse directly: `curl https://synapse-production-e979.up.railway.app/_matrix/static/`
3. Check browser console (F12) for CORS errors
4. Ensure both use HTTPS (not mixed HTTP/HTTPS)

### Database Connection Refused

**Cause**: PostgreSQL credentials wrong or database not running

**Check**:
```bash
# From any Railway service, test connection:
psql postgresql://postgres:PASSWORD@postgres.railway.internal:5432/railway

# Should show PostgreSQL prompt
```

**If fails**:
1. Copy correct password from Railway environment variables
2. Verify PostgreSQL is running (green circle in Railway UI)
3. Check that service has `PGHOST`, `PGUSER`, `PGPASSWORD` set

### Users Cannot Register

**Check settings**:
```yaml
enable_registration: true
enable_registration_without_verification: true
```

**If disabled**:
- Only admin can create users via CLI
- Users cannot self-register
- Recommended for production

---

## Next Steps

### 1. Production Hardening

**Move hardcoded secrets to environment variables**:

```yaml
# Instead of:
password: eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC

# Use:
password: ${SYNAPSE_DB_PASSWORD}
```

In Railway UI:
- Service Settings → Variables
- Add each environment variable
- Re-deploy service

**Recommended secrets to move**:
- Database passwords
- registration_shared_secret
- macaroon_secret_key
- form_secret
- API tokens

### 2. Enable SMTP for Email

```yaml
# In MAS config.yaml
email:
  transport: smtp
  smtp:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: ${SMTP_PASSWORD}
    tls: true
```

This enables:
- Email verification for registration
- Password reset emails
- User notifications

### 3. Configure Custom Domain

**If using custom domain** (e.g., `matrix.example.com`):

1. Update DNS:
```
matrix.example.com  A  <Railway_IP>
```

2. Update configuration:
```yaml
server_name: "example.com"  # User ID: @user:example.com
public_baseurl: "https://matrix.example.com/"
```

3. Set up HTTPS (use Let's Encrypt via cert-manager or Railway proxy)

### 4. Set Up Backup Strategy

**Backup PostgreSQL**:
```bash
# Automated backup (Railway Pro feature)
# Or manual:
pg_dump postgresql://postgres:pass@host/railway > backup.sql
```

**Backup media**:
- Mount S3 for `media_store` path
- Synapse supports S3 natively

### 5. Enable Federation

**Current state**: Can communicate with other Matrix servers

**To enable**:
1. Ensure `well_known_ip_range_blacklist` is set (prevents SSRF)
2. Test with Federation Tester
3. Public DNS must resolve your domain

**Create test message to matrix.org**:
1. Open Element Web
2. Join `#test:matrix.org`
3. Should see messages from users on matrix.org

### 6. Set Up Monitoring

**Recommended tools**:
- **Prometheus**: Metrics export (built-in to Synapse)
- **Grafana**: Visualization
- **Alertmanager**: Alerts for down services

**Key metrics to monitor**:
- Synapse CPU/memory
- Database connection pool
- Message throughput
- Failed logins
- API latency

### 7. Enable Encryption

Matrix E2E encryption is already supported:
- Synapse handles key distribution
- Element Web handles encryption/decryption
- No additional configuration needed

Users can enable "End-to-end encryption" in room settings.

### 8. Performance Tuning

**For production with many users**:

```yaml
# Synapse config - increase pool sizes
database:
  args:
    cp_min: 10      # From 5
    cp_max: 20      # From 10

# Consider horizontal scaling with multiple Synapse instances
```

**Use read replicas** for PostgreSQL (Railway Pro)

---

## Deployment Checklist

- [ ] Repository structured with `railway-deployment/` folder
- [ ] All configuration files created and tested locally
- [ ] PostgreSQL instances created (2 separate databases)
- [ ] Services deployed to Railway
- [ ] Synapse health endpoint returns 200 OK
- [ ] MAS health endpoint returns 200 OK
- [ ] Element Web login page loads
- [ ] Can register user and login
- [ ] Can create room and send message
- [ ] Federation test passes
- [ ] Secrets moved to environment variables (production)
- [ ] SMTP configured for email (production)
- [ ] Custom domain configured (if applicable)
- [ ] Backup strategy implemented
- [ ] Monitoring set up

---

## Quick Reference

### Important URLs
- **Synapse Admin**: `https://synapse-production-e979.up.railway.app/_synapse/admin/`
- **MAS Admin**: `https://mas-service-production.up.railway.app/admin`
- **Element Web**: `https://ess-helm-production.up.railway.app/`
- **Federation Tester**: `https://federationtester.matrix.org/`

### Database Credentials (from Railway UI)
- **Synapse DB**: `postgres.railway.internal:5432/railway`
- **MAS DB**: `postgres-h2zw.railway.internal:5432/railway`
- **User**: `postgres`
- **Passwords**: Available in Railway environment variables

### Key Secrets (Generated)
- **Registration Shared Secret**: `4578b92c30adf6e1`
- **Macaroon Secret Key**: `6f01b8a9c5e2d437`
- **Form Secret**: `32f4cb150ed867a9`
- **Encryption Key**: `c07af15b849e23d6f9a1b4c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7`

### Common Commands

```bash
# Check service logs
# (In Railway UI: Service → Logs)

# Test Synapse
curl https://synapse-production-e979.up.railway.app/_matrix/static/

# Test MAS
curl https://mas-service-production.up.railway.app/health

# Connect to database
psql postgresql://postgres:PASSWORD@postgres.railway.internal:5432/railway

# View Synapse version
curl https://synapse-production-e979.up.railway.app/_synapse/admin/v1/server_version
```

### File Locations (in containers)

| Service | Path | Purpose |
|---------|------|---------|
| Synapse | `/data/homeserver.yaml` | Main configuration |
| Synapse | `/data/media_store` | User uploads (avatars, media) |
| Synapse | `/data/*.signing.key` | Federation signing key |
| MAS | `/config.yaml` | Main configuration |
| Element | `/app/config.json` | Client configuration |

---

## Support & Resources

- **Matrix Spec**: https://spec.matrix.org
- **Synapse Admin Guide**: https://matrix-org.github.io/synapse/latest/
- **MAS Documentation**: https://element-hq.github.io/matrix-authentication-service/
- **Element Web Docs**: https://element.io/
- **Railway Docs**: https://docs.railway.app
- **Matrix Community**: https://matrix.to/#/#matrix:matrix.org

---

## Glossary

- **Federation**: Ability of Matrix servers to communicate with each other
- **Homeserver**: Your Matrix server (Synapse)
- **User ID**: Format `@username:server.name`
- **Room**: Conversation space (like Slack channels)
- **OIDC**: OpenID Connect (authentication protocol used by MAS)
- **E2E Encryption**: End-to-end encrypted messages
- **Well-known**: DNS configuration for server discovery
- **Macaroon**: Credential/token used by Synapse
- **MAS**: Matrix Authentication Service (handles user auth)
- **PSK**: Pre-Shared Key (like registration_shared_secret)

---

**Document Version**: 1.0  
**Created**: February 2, 2026  
**Last Updated**: February 2, 2026  
**Status**: Production Deployment Guide
