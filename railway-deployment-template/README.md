# 🚀 Railway Matrix Stack Deployment Template

## Overview
This template provides a production-ready, reusable deployment configuration for running a complete Matrix communication stack on Railway.app with proper environment variable management and security best practices.

## Services Included
- **Synapse** - Matrix homeserver
- **MAS (Matrix Authentication Service)** - User authentication
- **Element Web** - Web client
- **PostgreSQL** - Two separate database instances (via Railway plugin)

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Service Configurations](#service-configurations)
3. [Environment Variables](#environment-variables)
# Matrix Stack Railway Deployment Template
---
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new)

Production-ready, security-hardened Matrix communication stack (Synapse + MAS + Element Web) deployment template for Railway.app. Uses environment variables for all configuration - no hardcoded secrets.
## Quick Start
---

## ✨ Features
### Prerequisites
- **🔐 Security First**: Environment variables for all secrets, no hardcoded credentials
- **🚀 One-Click Deployment**: Pre-configured Railway templates for each service
- **📦 Modular Architecture**: Independent services that can be deployed separately
- **🔄 Auto-Migrations**: Database migrations run automatically on startup
- **📊 Health Checks**: Built-in health monitoring for all services
- **📖 Complete Documentation**: Comprehensive guides for deployment and maintenance
- **🛡️ Production Ready**: Follows Matrix.org and OWASP security best practices
1. Railway.app account
---
2. Git repository (GitHub/GitLab)
## 📋 What's Included
3. Domain name (optional, can use Railway-provided domains)
| Service | Description | Base Image |
|---------|-------------|------------|
| **Synapse** | Matrix homeserver | `matrixdotorg/synapse:latest` |
| **MAS** | Matrix Authentication Service | `ghcr.io/matrix-org/matrix-authentication-service:latest` |
| **Element Web** | Web-based Matrix client | `vectorim/element-web:latest` |
| **PostgreSQL** | Database (2 instances) | Railway-managed |

---
### Setup Steps
## 🚀 Quick Start
1. Fork this repository
### Prerequisites
1. Railway.app account
2. Git repository (GitHub/GitLab)
3. Domain name (optional, can use Railway-provided domains)
2. Create Railway project
### Setup Steps
1. Fork this repository
2. Create Railway project
3. Add PostgreSQL databases (2 instances)
4. Configure environment variables
5. Deploy services
6. Test endpoints
3. Add PostgreSQL databases (2 instances)
---
4. Configure environment variables
## Service Configurations
5. Deploy services
### 1. Synapse Configuration
6. Test endpoints
See `synapse/` directory for complete setup.

### 2. MAS Configuration
---
See `MAS-service/` directory for complete setup.

### 3. Element Web Configuration
## Service Configurations
See `element-web/` directory for complete setup.

---
### 1. Synapse Configuration
## Environment Variables

### Required Railway Variables
See `synapse/` directory for complete setup.
#### Synapse Service Variables
```bash
# Database Configuration
PGHOST=postgres.railway.internal              # Railway PostgreSQL hostname
PGPORT=5432                                    # PostgreSQL port
PGUSER=postgres                                # Database user
PGPASSWORD=<RAILWAY_PROVIDED>                  # From Railway PostgreSQL plugin
PGDATABASE=railway                             # Database name

# Server Configuration
SYNAPSE_SERVER_NAME=matrix.example.com         # Your Matrix server name
SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/  # Public URL
### 2. MAS Configuration
# Security Secrets (Generate with: openssl rand -hex 32)
SYNAPSE_REGISTRATION_SHARED_SECRET=<64_char_hex>
SYNAPSE_MACAROON_SECRET_KEY=<64_char_hex>
SYNAPSE_FORM_SECRET=<64_char_hex>

# Signing Key (Generate with Synapse, then store here)
SYNAPSE_SIGNING_KEY=ed25519 <key_id> <base64_key>
See `MAS-service/` directory for complete setup.
# Optional - Enable registration
SYNAPSE_ENABLE_REGISTRATION=false
SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=false
```

#### MAS Service Variables
```bash
# Database Configuration (Separate PostgreSQL instance)
MAS_PGHOST=postgres-mas.railway.internal       # Railway PostgreSQL hostname
MAS_PGPORT=5432
MAS_PGUSER=postgres
MAS_PGPASSWORD=<RAILWAY_PROVIDED>              # Different from Synapse DB
MAS_PGDATABASE=railway
### 3. Element Web Configuration
# Server Configuration
MAS_PUBLIC_BASE=https://auth.example.com/      # MAS public URL
MAS_HTTP_PORT=8080

# Matrix Integration
MAS_MATRIX_HOMESERVER=matrix.example.com       # Match Synapse server name
MAS_MATRIX_ENDPOINT=https://matrix.example.com # Synapse public URL
MAS_MATRIX_SECRET=<64_char_hex>                # Must match Synapse registration secret
See `element-web/` directory for complete setup.
# Synapse OAuth Client
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<64_char_hex>                # Must match MAS_MATRIX_SECRET

# Cryptographic Secrets (Generate with: openssl rand -hex 64)
MAS_ENCRYPTION_SECRET=<128_char_hex>
---
# EC Private Key (Generate with: openssl ecparam -name prime256v1 -genkey)
# Store the entire PEM-formatted key in this variable
MAS_SIGNING_KEY=-----BEGIN EC PRIVATE KEY-----
<base64_content>
-----END EC PRIVATE KEY-----

# Optional - Email Configuration
MAS_EMAIL_FROM=Matrix <noreply@example.com>
MAS_EMAIL_REPLY_TO=Support <support@example.com>
MAS_SMTP_HOST=smtp.example.com
MAS_SMTP_PORT=587
MAS_SMTP_USERNAME=<smtp_username>
MAS_SMTP_PASSWORD=<smtp_password>
```
## Environment Variables
#### Element Web Service Variables
```bash
# Synapse Connection
ELEMENT_HOMESERVER_URL=https://matrix.example.com
ELEMENT_HOMESERVER_NAME=matrix.example.com

# Branding (Optional)
ELEMENT_BRAND=Element
ELEMENT_DEFAULT_THEME=light
ELEMENT_DEFAULT_COUNTRY_CODE=US
```
### Required Railway Variables
### Secret Generation Commands

```bash
# Generate 64-character hex secrets (for most secrets)
openssl rand -hex 32
#### Synapse Service Variables
# Generate 128-character hex secrets (for encryption)
openssl rand -hex 64
```bash
# Generate EC Private Key (for MAS signing)
openssl ecparam -name prime256v1 -genkey -noout
# Database Configuration
# Generate Ed25519 Signing Key (for Synapse)
# Run Synapse with --generate-keys flag, then copy the generated key
```
PGHOST=postgres.railway.internal              # Railway PostgreSQL hostname
---
PGPORT=5432                                    # PostgreSQL port
## Security Best Practices
PGUSER=postgres                                # Database user
### 1. Never Commit Secrets
```bash
# Add to .gitignore
*.key
*.pem
*secret*
.env
.env.*
config.local.*
secrets/
```
PGPASSWORD=<RAILWAY_PROVIDED>                  # From Railway PostgreSQL plugin
### 2. Use Railway Secrets
All secrets should be stored in Railway's environment variables, not in code:
- Go to Railway Project → Service → Variables
- Add each secret as a separate variable
- Use descriptive names (e.g., `SYNAPSE_MACAROON_SECRET_KEY`)
PGDATABASE=railway                             # Database name
### 3. Separate Databases
- Use separate PostgreSQL instances for Synapse and MAS
- Different credentials for each service
- Prevents security issues if one database is compromised

### 4. HTTPS Only
- Always use HTTPS URLs in public_baseurl
- Railway provides automatic SSL certificates
- Never expose HTTP-only endpoints
# Server Configuration
### 5. Disable Open Registration
- Set `SYNAPSE_ENABLE_REGISTRATION=false` in production
- Only allow admin-created accounts
- Prevents spam and abuse
SYNAPSE_SERVER_NAME=matrix.example.com         # Your Matrix server name
### 6. Rotate Secrets Regularly
- Change database passwords quarterly
- Regenerate signing keys annually
- Update OAuth secrets after any security incident
SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/  # Public URL
### 7. Environment-Specific Configurations
- Use different secrets for staging vs production
- Separate Railway projects for each environment
- Never use production secrets in development

---
# Security Secrets (Generate with: openssl rand -hex 32)
## Deployment Guide
SYNAPSE_REGISTRATION_SHARED_SECRET=<64_char_hex>
### Step 1: Prepare Repository
SYNAPSE_MACAROON_SECRET_KEY=<64_char_hex>
```bash
# Clone your fork
git clone https://github.com/yourusername/matrix-railway-template.git
cd matrix-railway-template
SYNAPSE_FORM_SECRET=<64_char_hex>
# Create Railway-specific branch (optional)
git checkout -b railway-deployment
```

### Step 2: Create Railway Project
# Signing Key (Generate with Synapse, then store here)
1. Go to Railway.app
2. Create new project
3. Connect your repository
4. Add PostgreSQL plugin (twice - one for Synapse, one for MAS)
SYNAPSE_SIGNING_KEY=ed25519 <key_id> <base64_key>
### Step 3: Configure Environment Variables

For each service, add all required environment variables listed above.
# Optional - Enable registration
**Copy Template:**
```bash
# In Railway UI: Project → Service → Variables → Add Variables
SYNAPSE_ENABLE_REGISTRATION=false
# For Synapse:
PGHOST=postgres.railway.internal
PGUSER=postgres
PGPASSWORD=<from_railway_plugin>
# ... (add all Synapse variables)
SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=false
# For MAS:
MAS_PGHOST=postgres-mas.railway.internal
# ... (add all MAS variables)
```
# For Element Web:
ELEMENT_HOMESERVER_URL=https://your-domain.com
# ... (add all Element variables)
```

### Step 4: Deploy Services
#### MAS Service Variables
Railway will automatically:
1. Build Docker images
2. Run migrations (via entrypoint scripts)
3. Start services
4. Assign public URLs
```bash
### Step 5: Verify Deployment
# Database Configuration (Separate PostgreSQL instance)
```bash
# Test Synapse
curl https://your-synapse-url.up.railway.app/_matrix/static/
MAS_PGHOST=postgres-mas.railway.internal       # Railway PostgreSQL hostname
# Test MAS
curl https://your-mas-url.up.railway.app/health
MAS_PGPORT=5432
# Test Element Web
curl https://your-element-url.up.railway.app/
```
MAS_PGUSER=postgres
### Step 6: Create First User
MAS_PGPASSWORD=<RAILWAY_PROVIDED>              # Different from Synapse DB
```bash
# SSH into MAS container on Railway (or use Railway CLI)
mas-cli manage register-user
MAS_PGDATABASE=railway
# Follow prompts to create admin user
```

---
# Server Configuration
## Customization
MAS_PUBLIC_BASE=https://auth.example.com/      # MAS public URL
### Using Your Own Domain
MAS_HTTP_PORT=8080
1. **Configure DNS:**
   ```
   matrix.example.com    A/CNAME  → Synapse Railway URL
   auth.example.com      A/CNAME  → MAS Railway URL
   chat.example.com      A/CNAME  → Element Web Railway URL
   ```

2. **Update Environment Variables:**
   ```bash
   SYNAPSE_SERVER_NAME=example.com
   SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/
   MAS_PUBLIC_BASE=https://auth.example.com/
   ELEMENT_HOMESERVER_URL=https://matrix.example.com
   ```
# Matrix Integration
3. **Railway handles SSL automatically**
MAS_MATRIX_HOMESERVER=matrix.example.com       # Match Synapse server name
### Scaling Options
MAS_MATRIX_ENDPOINT=https://matrix.example.com # Synapse public URL
#### Vertical Scaling
Increase service resources in Railway UI:
- CPU: 1-8 vCPUs
- Memory: 512MB-32GB
- Storage: 1GB-100GB
MAS_MATRIX_SECRET=<64_char_hex>                # Must match Synapse registration secret
#### Horizontal Scaling (Advanced)
- Use multiple Synapse workers
- Load balance with Railway's networking
- Implement read replicas for PostgreSQL

### Custom Branding
# Synapse OAuth Client
Update Element Web variables:
```bash
ELEMENT_BRAND=YourCompany
ELEMENT_DEFAULT_THEME=dark
ELEMENT_ROOM_DIRECTORY_SERVERS=matrix.org,your-server.com
```
MAS_CLIENT_ID=0000000000000000000SYNAPSE
### Email Notifications
MAS_CLIENT_SECRET=<64_char_hex>                # Must match MAS_MATRIX_SECRET
Configure SMTP in MAS variables:
```bash
MAS_SMTP_HOST=smtp.sendgrid.net
MAS_SMTP_PORT=587
MAS_SMTP_USERNAME=apikey
MAS_SMTP_PASSWORD=SG.xxxxx
```

---
# Cryptographic Secrets (Generate with: openssl rand -hex 64)
## Directory Structure
MAS_ENCRYPTION_SECRET=<128_char_hex>
```
matrix-railway-template/
├── README.md                          # This file
├── DEPLOYMENT_TEMPLATE.md             # Detailed guide
│
├── synapse/
│   ├── Dockerfile                     # Multi-stage build with env vars
│   ├── homeserver.yaml.template       # Config template with ${VAR} placeholders
│   ├── entrypoint.sh                  # Startup script with migrations
│   ├── railway.json                   # Railway-specific config
│   └── log.config.yaml                # Logging configuration
│
├── MAS-service/
│   ├── Dockerfile                     # Multi-stage build
│   ├── config.yaml.template           # Config template with ${VAR} placeholders
│   ├── entrypoint.sh                  # Startup script with migrations
│   └── railway.json                   # Railway-specific config
│
├── element-web/
│   ├── Dockerfile                     # Static file build
│   ├── config.json.template           # Config template with ${VAR} placeholders
│   ├── entrypoint.sh                  # Runtime config injection
│   └── railway.json                   # Railway-specific config
│
└── docs/
    ├── ENVIRONMENT_VARIABLES.md       # Complete variable reference
    ├── SECURITY.md                    # Security best practices
    ├── TROUBLESHOOTING.md             # Common issues and solutions
    └── CUSTOMIZATION.md               # Advanced customization guide
```

---
# EC Private Key (Generate with: openssl ecparam -name prime256v1 -genkey)
## Railway Configuration Files
# Store the entire PEM-formatted key in this variable
Each service includes a `railway.json` for Railway-specific settings:
MAS_SIGNING_KEY=-----BEGIN EC PRIVATE KEY-----
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "startCommand": "/entrypoint.sh",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```
<base64_content>
---
-----END EC PRIVATE KEY-----
## Monitoring & Maintenance

### Health Checks
# Optional - Email Configuration
Railway automatically monitors:
- HTTP response codes
- Container restarts
- Resource usage
MAS_EMAIL_FROM=Matrix <noreply@example.com>
### Logs
MAS_EMAIL_REPLY_TO=Support <support@example.com>
View logs in Railway UI:
- Project → Service → Logs
- Filter by time range
- Search for errors
MAS_SMTP_HOST=smtp.example.com
### Backups
MAS_SMTP_PORT=587
Set up automated backups:
```bash
# PostgreSQL backup (via Railway CLI or custom script)
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql
```
MAS_SMTP_USERNAME=<smtp_username>
---
MAS_SMTP_PASSWORD=<smtp_password>
## Troubleshooting
```
### Service Won't Start

1. Check Railway logs for errors
2. Verify all environment variables are set
3. Confirm database connections work
4. Check that secrets are properly formatted
#### Element Web Service Variables
### Database Connection Failed
```bash
```bash
# Test connection manually
psql $DATABASE_URL
# Synapse Connection
# Check variables
echo $PGHOST
echo $PGUSER
```
ELEMENT_HOMESERVER_URL=https://matrix.example.com
### MAS PEM Key Error
ELEMENT_HOMESERVER_NAME=matrix.example.com
```bash
# Regenerate EC key
openssl ecparam -name prime256v1 -genkey -noout > private.pem

# Copy entire key including BEGIN/END lines to MAS_SIGNING_KEY variable
cat private.pem
```
# Branding (Optional)
---
ELEMENT_BRAND=Element
## Contributing
ELEMENT_DEFAULT_THEME=light
To improve this template:
1. Fork the repository
2. Make your changes
3. Test thoroughly
4. Submit a pull request
ELEMENT_DEFAULT_COUNTRY_CODE=US
---
```
## License

This template is provided as-is for educational and commercial use. Modify as needed for your deployment.
### Secret Generation Commands
---

## Support
```bash
- **Matrix Documentation**: https://matrix.org/docs/
- **Synapse Docs**: https://matrix-org.github.io/synapse/
- **MAS Docs**: https://element-hq.github.io/matrix-authentication-service/
- **Railway Docs**: https://docs.railway.app
# Generate 64-character hex secrets (for most secrets)
---
openssl rand -hex 32
## Changelog

### v1.0.0 (February 2026)
- Initial release
- Environment variable support for all services
- Security best practices implemented
- Railway.app optimized configurations
- Complete documentation
# Generate 128-character hex secrets (for encryption)
---
openssl rand -hex 64
**Ready to deploy? Start with the service-specific README files in each directory!**

# Generate EC Private Key (for MAS signing)
openssl ecparam -name prime256v1 -genkey -noout

# Generate Ed25519 Signing Key (for Synapse)
# Run Synapse with --generate-keys flag, then copy the generated key
```

---

## Security Best Practices

### 1. Never Commit Secrets
```bash
# Add to .gitignore
*.key
*.pem
*secret*
.env
.env.*
config.local.*
secrets/
```

### 2. Use Railway Secrets
All secrets should be stored in Railway's environment variables, not in code:
- Go to Railway Project → Service → Variables
- Add each secret as a separate variable
- Use descriptive names (e.g., `SYNAPSE_MACAROON_SECRET_KEY`)

### 3. Separate Databases
- Use separate PostgreSQL instances for Synapse and MAS
- Different credentials for each service
- Prevents security issues if one database is compromised

### 4. HTTPS Only
- Always use HTTPS URLs in public_baseurl
- Railway provides automatic SSL certificates
- Never expose HTTP-only endpoints

### 5. Disable Open Registration
- Set `SYNAPSE_ENABLE_REGISTRATION=false` in production
- Only allow admin-created accounts
- Prevents spam and abuse

### 6. Rotate Secrets Regularly
- Change database passwords quarterly
- Regenerate signing keys annually
- Update OAuth secrets after any security incident

### 7. Environment-Specific Configurations
- Use different secrets for staging vs production
- Separate Railway projects for each environment
- Never use production secrets in development

---

## Deployment Guide

### Step 1: Prepare Repository

```bash
# Clone your fork
git clone https://github.com/yourusername/matrix-railway-template.git
cd matrix-railway-template

# Create Railway-specific branch (optional)
git checkout -b railway-deployment
```

### Step 2: Create Railway Project

1. Go to Railway.app
2. Create new project
3. Connect your repository
4. Add PostgreSQL plugin (twice - one for Synapse, one for MAS)

### Step 3: Configure Environment Variables

For each service, add all required environment variables listed above.

**Copy Template:**
```bash
# In Railway UI: Project → Service → Variables → Add Variables

# For Synapse:
PGHOST=postgres.railway.internal
PGUSER=postgres
PGPASSWORD=<from_railway_plugin>
# ... (add all Synapse variables)

# For MAS:
MAS_PGHOST=postgres-mas.railway.internal
# ... (add all MAS variables)

# For Element Web:
ELEMENT_HOMESERVER_URL=https://your-domain.com
# ... (add all Element variables)
```

### Step 4: Deploy Services

Railway will automatically:
1. Build Docker images
2. Run migrations (via entrypoint scripts)
3. Start services
4. Assign public URLs

### Step 5: Verify Deployment

```bash
# Test Synapse
curl https://your-synapse-url.up.railway.app/_matrix/static/

# Test MAS
curl https://your-mas-url.up.railway.app/health

# Test Element Web
curl https://your-element-url.up.railway.app/
```

### Step 6: Create First User

```bash
# SSH into MAS container on Railway (or use Railway CLI)
mas-cli manage register-user

# Follow prompts to create admin user
```

---

## Customization

### Using Your Own Domain

1. **Configure DNS:**
   ```
   matrix.example.com    A/CNAME  → Synapse Railway URL
   auth.example.com      A/CNAME  → MAS Railway URL
   chat.example.com      A/CNAME  → Element Web Railway URL
   ```

2. **Update Environment Variables:**
   ```bash
   SYNAPSE_SERVER_NAME=example.com
   SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/
   MAS_PUBLIC_BASE=https://auth.example.com/
   ELEMENT_HOMESERVER_URL=https://matrix.example.com
   ```

3. **Railway handles SSL automatically**

### Scaling Options

#### Vertical Scaling
Increase service resources in Railway UI:
- CPU: 1-8 vCPUs
- Memory: 512MB-32GB
- Storage: 1GB-100GB

#### Horizontal Scaling (Advanced)
- Use multiple Synapse workers
- Load balance with Railway's networking
- Implement read replicas for PostgreSQL

### Custom Branding

Update Element Web variables:
```bash
ELEMENT_BRAND=YourCompany
ELEMENT_DEFAULT_THEME=dark
ELEMENT_ROOM_DIRECTORY_SERVERS=matrix.org,your-server.com
```

### Email Notifications

Configure SMTP in MAS variables:
```bash
MAS_SMTP_HOST=smtp.sendgrid.net
MAS_SMTP_PORT=587
MAS_SMTP_USERNAME=apikey
MAS_SMTP_PASSWORD=SG.xxxxx
```

---

## Directory Structure

```
matrix-railway-template/
├── README.md                          # This file
├── DEPLOYMENT_TEMPLATE.md             # Detailed guide
│
├── synapse/
│   ├── Dockerfile                     # Multi-stage build with env vars
│   ├── homeserver.yaml.template       # Config template with ${VAR} placeholders
│   ├── entrypoint.sh                  # Startup script with migrations
│   ├── railway.json                   # Railway-specific config
│   └── log.config.yaml                # Logging configuration
│
├── MAS-service/
│   ├── Dockerfile                     # Multi-stage build
│   ├── config.yaml.template           # Config template with ${VAR} placeholders
│   ├── entrypoint.sh                  # Startup script with migrations
│   └── railway.json                   # Railway-specific config
│
├── element-web/
│   ├── Dockerfile                     # Static file build
│   ├── config.json.template           # Config template with ${VAR} placeholders
│   ├── entrypoint.sh                  # Runtime config injection
│   └── railway.json                   # Railway-specific config
│
└── docs/
    ├── ENVIRONMENT_VARIABLES.md       # Complete variable reference
    ├── SECURITY.md                    # Security best practices
    ├── TROUBLESHOOTING.md             # Common issues and solutions
    └── CUSTOMIZATION.md               # Advanced customization guide
```

---

## Railway Configuration Files

Each service includes a `railway.json` for Railway-specific settings:

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "startCommand": "/entrypoint.sh",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

---

## Monitoring & Maintenance

### Health Checks

Railway automatically monitors:
- HTTP response codes
- Container restarts
- Resource usage

### Logs

View logs in Railway UI:
- Project → Service → Logs
- Filter by time range
- Search for errors

### Backups

Set up automated backups:
```bash
# PostgreSQL backup (via Railway CLI or custom script)
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql
```

---

## Troubleshooting

### Service Won't Start

1. Check Railway logs for errors
2. Verify all environment variables are set
3. Confirm database connections work
4. Check that secrets are properly formatted

### Database Connection Failed

```bash
# Test connection manually
psql $DATABASE_URL

# Check variables
echo $PGHOST
echo $PGUSER
```

### MAS PEM Key Error

```bash
# Regenerate EC key
openssl ecparam -name prime256v1 -genkey -noout > private.pem

# Copy entire key including BEGIN/END lines to MAS_SIGNING_KEY variable
cat private.pem
```

---

## Contributing

To improve this template:
1. Fork the repository
2. Make your changes
3. Test thoroughly
4. Submit a pull request

---

## License

This template is provided as-is for educational and commercial use. Modify as needed for your deployment.

---

## Support

- **Matrix Documentation**: https://matrix.org/docs/
- **Synapse Docs**: https://matrix-org.github.io/synapse/
- **MAS Docs**: https://element-hq.github.io/matrix-authentication-service/
- **Railway Docs**: https://docs.railway.app

---

## Changelog

### v1.0.0 (February 2026)
- Initial release
- Environment variable support for all services
- Security best practices implemented
- Railway.app optimized configurations
- Complete documentation

---

**Ready to deploy? Start with the service-specific README files in each directory!**
