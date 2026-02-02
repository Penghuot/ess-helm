# 🚀 Step-by-Step Deployment Guide

## Overview
This guide walks you through deploying a complete Matrix stack (Synapse + MAS + Element Web) on Railway.app from scratch. Follow each step carefully to ensure a successful deployment.

**Estimated Time**: 30-45 minutes

---

## Prerequisites

### Required Accounts
- [ ] Railway.app account (free tier available)
- [ ] GitHub or GitLab account
- [ ] Domain name (optional, can use Railway-provided domains)

### Required Tools
- [ ] Git installed locally
- [ ] OpenSSL (for secret generation)
- [ ] Text editor

### Knowledge Requirements
- Basic command line usage
- Understanding of environment variables
- Basic Git operations

---

## 🎯 Phase 1: Repository Setup

### Step 1.1: Fork/Clone the Template

```bash
# Option A: Fork on GitHub
# Go to: https://github.com/yourusername/matrix-railway-template
# Click "Fork"

# Option B: Clone directly
git clone https://github.com/yourusername/matrix-railway-template.git
cd matrix-railway-template
```

### Step 1.2: Create Your Deployment Branch

```bash
# Create a deployment branch (optional but recommended)
git checkout -b production-deployment

# Or use existing main branch
git checkout main
```

### Step 1.3: Verify Template Structure

```bash
# Check directory structure
ls -la

# Should see:
# ├── README.md
# ├── synapse/
# │   ├── Dockerfile
# │   ├── homeserver.yaml.template
# │   ├── entrypoint.sh
# │   └── railway.json
# ├── MAS-service/
# │   ├── Dockerfile
# │   ├── config.yaml.template
# │   ├── entrypoint.sh
# │   └── railway.json
# ├── element-web/
# │   ├── Dockerfile
# │   ├── config.json.template
# │   ├── entrypoint.sh
# │   └── railway.json
# ├── scripts/
# │   └── generate_secrets.sh
# └── docs/
```

---

## 🔐 Phase 2: Generate Secrets

### Step 2.1: Run Secret Generator

```bash
# Make script executable
chmod +x scripts/generate_secrets.sh

# Run generator
./scripts/generate_secrets.sh
```

**Expected Output:**
```
==================================================
Matrix Stack Secret Generator
==================================================

Generating secrets...
✓ Secrets Generated Successfully

---------- SYNAPSE SERVICE ----------
SYNAPSE_REGISTRATION_SHARED_SECRET=4578b92c...
SYNAPSE_MACAROON_SECRET_KEY=6f01b8a9...
...
```

### Step 2.2: Save Secrets Securely

**Option A: Password Manager (Recommended)**
1. Copy entire output
2. Save in secure password manager (1Password, Bitwarden, etc.)
3. Label as "Matrix Railway Secrets - Production"

**Option B: Encrypted File (Temporary)**
1. Script offers to save to file
2. If saved, use: `secrets_YYYYMMDD_HHMMSS.txt`
3. **Delete file after copying to Railway!**

### Step 2.3: Verify Secret Format

**Check MAS Signing Key:**
```bash
# Should look like:
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIJGlh975aqLDMRj14FmkOb5BB89gS8q1EdWAqfTQAnozo...
-----END EC PRIVATE KEY-----

# NOT like:
${MAS_SIGNING_KEY}  # ❌ Wrong!
```

---

## 🚂 Phase 3: Railway Project Setup

### Step 3.1: Create New Railway Project

1. Go to [railway.app](https://railway.app)
2. Click "New Project"
3. Select "Empty Project"
4. Name: `matrix-production` (or your preferred name)

### Step 3.2: Add PostgreSQL Databases

**For Synapse:**
1. Click "+ New" → "Database" → "PostgreSQL"
2. Name: `postgres-synapse`
3. Wait for provisioning (~30 seconds)
4. Click database → "Variables" tab
5. **Copy these values:**
   - `PGHOST` (e.g., `postgres.railway.internal`)
   - `PGUSER` (usually `postgres`)
   - `PGPASSWORD` (e.g., `eEFsjzqX...`)
   - `PGDATABASE` (usually `railway`)
   - `PGPORT` (usually `5432`)

**For MAS (Separate Database):**
1. Click "+ New" → "Database" → "PostgreSQL"
2. Name: `postgres-mas`
3. Wait for provisioning
4. Copy variables (similar to above)
5. Note: These will be different from Synapse DB

### Step 3.3: Connect GitHub Repository

**For each service (Synapse, MAS, Element Web):**

1. Click "+ New" → "GitHub Repo"
2. Select your forked repository
3. Railway asks: "Which service?"
4. Choose root directory (we'll configure paths next)

**Or use Railway CLI:**
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Link project
railway link

# Deploy services
railway up --service synapse
railway up --service mas
railway up --service element-web
```

---

## ⚙️ Phase 4: Configure Services

### Step 4.1: Configure Synapse Service

**In Railway Dashboard:**
1. Select "Synapse" service
2. Click "Settings" tab
3. **Dockerfile Path**: `synapse/Dockerfile`
4. **Root Directory**: `/`
5. Click "Variables" tab
6. Click "New Variable" for each:

```bash
# Database (from PostgreSQL plugin)
PGHOST=postgres.railway.internal
PGPORT=5432
PGUSER=postgres
PGPASSWORD=<FROM_POSTGRES_PLUGIN>
PGDATABASE=railway

# Server Configuration
SYNAPSE_SERVER_NAME=matrix.example.com          # ⚠️ REPLACE WITH YOUR DOMAIN
SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/  # ⚠️ MUST END WITH /

# Secrets (from generate_secrets.sh)
SYNAPSE_REGISTRATION_SHARED_SECRET=<FROM_SCRIPT>
SYNAPSE_MACAROON_SECRET_KEY=<FROM_SCRIPT>
SYNAPSE_FORM_SECRET=<FROM_SCRIPT>
SYNAPSE_PASSWORD_PEPPER=<FROM_SCRIPT>

# Optional Settings
SYNAPSE_ENABLE_REGISTRATION=false
SYNAPSE_REPORT_STATS=false
SYNAPSE_PRESENCE_ENABLED=true
```

7. Click "Deploy" (or wait for auto-deploy)

### Step 4.2: Configure MAS Service

**In Railway Dashboard:**
1. Select "MAS" service
2. Click "Settings" tab
3. **Dockerfile Path**: `MAS-service/Dockerfile`
4. **Root Directory**: `/`
5. Click "Variables" tab
6. Click "New Variable" for each:

```bash
# Database (from SEPARATE PostgreSQL plugin)
MAS_PGHOST=postgres-mas.railway.internal
MAS_PGPORT=5432
MAS_PGUSER=postgres
MAS_PGPASSWORD=<FROM_POSTGRES_MAS_PLUGIN>
MAS_PGDATABASE=railway

# Server Configuration
MAS_PUBLIC_BASE=https://auth.example.com/       # ⚠️ REPLACE WITH YOUR DOMAIN
MAS_MATRIX_HOMESERVER=matrix.example.com        # ⚠️ MUST MATCH SYNAPSE_SERVER_NAME
MAS_MATRIX_ENDPOINT=https://matrix.example.com  # ⚠️ NO TRAILING /
MAS_HTTP_PORT=8080

# Secrets (from generate_secrets.sh)
MAS_ENCRYPTION_SECRET=<FROM_SCRIPT>
MAS_CLIENT_SECRET=<FROM_SCRIPT>
MAS_MATRIX_SECRET=<FROM_SCRIPT>  # ⚠️ MUST MATCH SYNAPSE_REGISTRATION_SHARED_SECRET

# EC Private Key (entire PEM content)
MAS_SIGNING_KEY=-----BEGIN EC PRIVATE KEY-----
<PASTE_ENTIRE_KEY_HERE>
-----END EC PRIVATE KEY-----

# OAuth Client
MAS_CLIENT_ID=0000000000000000000SYNAPSE

# Optional Settings
MAS_LOG_LEVEL=info
MAS_RATE_LIMITING_ENABLED=true
```

7. Click "Deploy"

### Step 4.3: Configure Element Web Service

**In Railway Dashboard:**
1. Select "Element Web" service
2. Click "Settings" tab
3. **Dockerfile Path**: `element-web/Dockerfile`
4. **Root Directory**: `/`
5. Click "Variables" tab
6. Click "New Variable" for each:

```bash
# Synapse Connection
ELEMENT_HOMESERVER_URL=https://matrix.example.com  # ⚠️ MUST MATCH SYNAPSE
ELEMENT_HOMESERVER_NAME=matrix.example.com         # ⚠️ MUST MATCH SYNAPSE

# Optional Branding
ELEMENT_BRAND=Element
ELEMENT_DEFAULT_THEME=light
ELEMENT_DISABLE_CUSTOM_URLS=false
```

7. Click "Deploy"

---

## 🌐 Phase 5: Domain Configuration

### Step 5.1: Get Railway-Provided Domains

**Each service gets a Railway domain:**
1. Select service (e.g., Synapse)
2. Click "Settings" → "Networking"
3. See: `synapse-production-xxx.up.railway.app`
4. **Copy this URL**

**Do this for:**
- Synapse: `https://synapse-production-xxx.up.railway.app`
- MAS: `https://mas-production-yyy.up.railway.app`
- Element Web: `https://element-production-zzz.up.railway.app`

### Step 5.2: Update Environment Variables with Railway Domains

**Option A: Use Railway Domains (Quick Start)**

Update these variables:
```bash
# Synapse
SYNAPSE_SERVER_NAME=synapse-production-xxx.up.railway.app
SYNAPSE_PUBLIC_BASEURL=https://synapse-production-xxx.up.railway.app/

# MAS
MAS_PUBLIC_BASE=https://mas-production-yyy.up.railway.app/
MAS_MATRIX_HOMESERVER=synapse-production-xxx.up.railway.app
MAS_MATRIX_ENDPOINT=https://synapse-production-xxx.up.railway.app

# Element Web
ELEMENT_HOMESERVER_URL=https://synapse-production-xxx.up.railway.app
ELEMENT_HOMESERVER_NAME=synapse-production-xxx.up.railway.app
```

**Option B: Use Custom Domains (Production)**

1. **Configure DNS:**
   ```
   matrix.example.com    CNAME  synapse-production-xxx.up.railway.app
   auth.example.com      CNAME  mas-production-yyy.up.railway.app
   chat.example.com      CNAME  element-production-zzz.up.railway.app
   ```

2. **Add Custom Domains in Railway:**
   - Select service → Settings → Networking → "Custom Domain"
   - Enter: `matrix.example.com`
   - Railway auto-provisions SSL certificate

3. **Update Variables:**
   ```bash
   SYNAPSE_SERVER_NAME=example.com  # Base domain for federation
   SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/
   MAS_PUBLIC_BASE=https://auth.example.com/
   ELEMENT_HOMESERVER_URL=https://matrix.example.com
   ```

---

## ✅ Phase 6: Verification

### Step 6.1: Check Service Health

**Synapse:**
```bash
# Health endpoint
curl https://synapse-production-xxx.up.railway.app/_matrix/static/

# Expected: HTML page with "Synapse is running"
```

**MAS:**
```bash
# Health endpoint
curl https://mas-production-yyy.up.railway.app/health

# Expected: {"status":"healthy"}
```

**Element Web:**
```bash
# Homepage
curl https://element-production-zzz.up.railway.app/

# Expected: HTML page with Element Web
```

### Step 6.2: Check Railway Logs

**For each service:**
1. Railway Dashboard → Service → "Logs" tab
2. Look for:
   - ✓ "Configuration file generated"
   - ✓ "Database connection successful"
   - ✓ "Starting [service name]..."
   - ❌ Any ERROR messages

**Common startup messages:**
```
Synapse:
  ✓ "Synapse now listening on TCP port 8008"
  ✓ "Database prepared"

MAS:
  ✓ "HTTP server listening on 0.0.0.0:8080"
  ✓ "Migrations complete"

Element Web:
  ✓ "nginx started successfully"
```

### Step 6.3: Test Database Connections

**From Railway Dashboard:**
1. Select PostgreSQL service
2. Click "Data" tab
3. Should see tables created:
   - **Synapse DB**: `users`, `rooms`, `events`, etc.
   - **MAS DB**: `users`, `oauth2_sessions`, etc.

---

## 🎉 Phase 7: First User Creation

### Step 7.1: Access Element Web

1. Open browser
2. Navigate to: `https://element-production-zzz.up.railway.app`
3. Click "Sign In"
4. Should see login page

### Step 7.2: Create Admin User via MAS

**Option A: Railway Terminal (Recommended)**
```bash
# In Railway Dashboard
1. Select "MAS" service
2. Click "..." menu → "Open Terminal"
3. Run:
   mas-cli manage register-user

# Follow prompts:
Username: admin
Password: <strong_password>
Email: admin@example.com
Admin privileges: yes
```

**Option B: Local MAS CLI (Advanced)**
```bash
# Install MAS CLI locally
cargo install mas-cli

# Connect to Railway database
export DATABASE_URL="postgresql://user:pass@host:5432/db"

# Create user
mas-cli manage register-user --admin
```

### Step 7.3: Test Login

1. Return to Element Web
2. Enter credentials:
   - Username: `@admin:matrix.example.com`
   - Password: `<your_admin_password>`
3. Click "Sign In"
4. Should see Element Web dashboard

---

## 🔍 Phase 8: Troubleshooting

### Service Won't Start

**Check logs for errors:**
```bash
# Railway Dashboard → Service → Logs

# Common errors:
ERROR: Missing required environment variables
  → Fix: Add missing variables

ERROR: Cannot connect to database
  → Fix: Verify PGHOST, PGPASSWORD are correct

ERROR: PEM preamble contains invalid data
  → Fix: Ensure MAS_SIGNING_KEY has complete PEM format
```

### Database Connection Failed

**Verify PostgreSQL plugins:**
1. Railway Dashboard → Project
2. Should see 2 PostgreSQL services
3. Both should be "Running" (green)

**Test connection:**
```bash
# From service terminal
psql $DATABASE_URL -c "SELECT 1;"

# Expected: 1 row returned
```

### MAS Won't Start (PEM Key Error)

**Check MAS_SIGNING_KEY format:**
```bash
# In Railway variables, key should look like:
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIJGlh975aqLDMRj14FmkOb5BB89gS8q1EdWAqfTQAnoz...
-----END EC PRIVATE KEY-----

# NOT like:
${MAS_SIGNING_KEY}  # Environment variable placeholder
<paste key here>    # Incomplete
```

**Regenerate if needed:**
```bash
openssl ecparam -name prime256v1 -genkey -noout

# Copy ENTIRE output including BEGIN/END lines
```

### Element Web Can't Connect

**Verify Synapse URL:**
1. Check `ELEMENT_HOMESERVER_URL` matches Synapse deployment
2. Test Synapse: `curl https://matrix.example.com/_matrix/static/`
3. Check browser console for CORS errors

**Common issues:**
- Synapse URL has typo
- Synapse not accessible (check Railway logs)
- Browser caching old config (hard refresh: Ctrl+Shift+R)

---

## 📋 Phase 9: Post-Deployment Checklist

### Security
- [ ] All secrets stored in Railway variables (not in code)
- [ ] Registration disabled (`SYNAPSE_ENABLE_REGISTRATION=false`)
- [ ] Admin user created successfully
- [ ] Database passwords unique and strong
- [ ] `.gitignore` configured to exclude secrets

### Functionality
- [ ] Synapse health endpoint responding
- [ ] MAS health endpoint responding
- [ ] Element Web loads successfully
- [ ] Can create and login with user account
- [ ] Can create a room
- [ ] Can send messages
- [ ] Federation working (optional, test with matrix.org)

### Monitoring
- [ ] Railway logs accessible for all services
- [ ] No errors in startup logs
- [ ] Database tables populated
- [ ] Service metrics visible in Railway dashboard

### Documentation
- [ ] Environment variables documented
- [ ] Admin credentials stored securely
- [ ] Domain configuration documented
- [ ] Team members have access to Railway project

---

## 🚀 Phase 10: Next Steps

### Immediate (Today)
1. Test all functionality thoroughly
2. Create additional user accounts (if needed)
3. Configure Element Web branding (optional)
4. Set up monitoring alerts

### Short Term (This Week)
1. Configure custom domain (if using)
2. Set up email notifications (SMTP)
3. Configure backup strategy
4. Review security settings

### Long Term (This Month)
1. Implement secret rotation schedule
2. Set up monitoring dashboard
3. Plan for scaling (if needed)
4. Document custom procedures

---

## 📚 Additional Resources

- **Railway Documentation**: https://docs.railway.app
- **Synapse Documentation**: https://matrix-org.github.io/synapse/
- **MAS Documentation**: https://element-hq.github.io/matrix-authentication-service/
- **Matrix Specification**: https://spec.matrix.org
- **Security Best Practices**: See [SECURITY.md](SECURITY.md)
- **Environment Variables**: See [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md)

---

## 🆘 Getting Help

### Railway Support
- **Discord**: https://discord.gg/railway
- **Help Docs**: https://docs.railway.app/reference/support

### Matrix Community
- **Matrix HQ**: `#matrix:matrix.org`
- **Synapse Admins**: `#synapse:matrix.org`

### Issues
- Report template issues on GitHub
- Include Railway logs (redact secrets!)
- Describe steps to reproduce

---

**Deployment Complete! 🎉**

Your Matrix stack is now running on Railway. Follow the Next Steps section to continue hardening and optimizing your deployment.
