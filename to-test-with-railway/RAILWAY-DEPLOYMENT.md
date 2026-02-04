# Railway Deployment Guide - Matrix Stack (Synapse + MAS + Element Web)

This guide will walk you through deploying your complete Matrix authentication stack on Railway.

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  Element    │─────▶│   Synapse    │─────▶│     MAS     │
│  Web/Desktop│      │  Homeserver  │      │    Auth     │
│  (Port 80)  │      │  (Port 8008) │      │ (Port 8080) │
└─────────────┘      └──────────────┘      └─────────────┘
                            │                      │
                            ▼                      ▼
                     ┌──────────────┐      ┌─────────────┐
                     │  PostgreSQL  │      │ PostgreSQL  │
                     │  (Synapse)   │      │   (MAS)     │
                     └──────────────┘      └─────────────┘
```

## 📋 Prerequisites

1. Railway account (https://railway.app)
2. GitHub account (for deploying from repo)
3. Generated secrets (see below)
4. MAS signing key

## 🔐 Generate Secrets First

Before deploying, generate all required secrets:

```bash
# Generate 64-character hex secrets (32 bytes)
openssl rand -hex 32  # For SYNAPSE_MACAROON_SECRET_KEY
openssl rand -hex 32  # For SYNAPSE_FORM_SECRET
openssl rand -hex 32  # For MAS_ENCRYPTION_KEY

# Generate registration shared secret
openssl rand -hex 32  # For SYNAPSE_REGISTRATION_SHARED_SECRET

# Generate client secret (can be any strong password, 40+ chars)
openssl rand -base64 32  # For MAS_CLIENT_SECRET
```

**Save these secrets!** You'll need them for Railway environment variables.

## 🚀 Railway Deployment Steps

### Step 1: Create Railway Project

1. Go to https://railway.app
2. Click "New Project"
3. Choose "Empty Project"
4. Name it: `matrix-stack`

### Step 2: Add PostgreSQL Databases

#### Synapse Database
1. Click "+ New Service"
2. Select "Database" → "PostgreSQL"
3. Name it: `synapse-db`
4. Railway will auto-create credentials

#### MAS Database
1. Click "+ New Service"
2. Select "Database" → "PostgreSQL"
3. Name it: `mas-db`
4. Railway will auto-create credentials

### Step 3: Deploy MAS Service

1. **Create Service:**
   - Click "+ New Service"
   - Select "GitHub Repo"
   - Connect your `ess-helm` repository
   - Set root directory: `to-test-with-railway/mas`

2. **Configure Build:**
   - Railway will auto-detect the Dockerfile
   - No additional build config needed

3. **Set Environment Variables:**

```bash
# === MAS Core ===
MAS_PUBLIC_BASE=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_LISTEN_ADDR=0.0.0.0:8080

# === Database (use Railway's internal URL) ===
MAS_DATABASE_URI=${{mas-db.DATABASE_URL}}

# === Synapse Integration ===
MAS_MATRIX_ENDPOINT=https://<synapse-railway-url>
MAS_MATRIX_SERVER_NAME=<synapse-railway-domain>
MAS_MATRIX_SHARED_SECRET=<your-generated-secret>
MAS_MATRIX_HOMESERVER=<synapse-railway-domain>

# === OIDC Client ===
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<your-generated-client-secret>
MAS_CLIENT_REDIRECT_URI=https://<synapse-railway-url>/_synapse/client/oidc/callback

# === Crypto ===
MAS_ENCRYPTION_KEY=<your-generated-64-char-hex>

# === Signing Key ===
MAS_SIGNING_KEY=<paste-your-pem-key-here>

# === Misc ===
MAS_EMAIL_DOMAIN=<your-domain-or-railway-domain>
```

4. **Generate Public URL:**
   - Go to "Settings" tab
   - Click "Generate Domain"
   - Save this URL - you'll need it for Synapse config

### Step 4: Deploy Synapse Service

1. **Create Service:**
   - Click "+ New Service"
   - Select "GitHub Repo"
   - Same repository
   - Set root directory: `to-test-with-railway/synapse`

2. **Set Environment Variables:**

```bash
# === Core ===
SYNAPSE_SERVER_NAME=${{RAILWAY_PUBLIC_DOMAIN}}
SYNAPSE_PUBLIC_BASEURL=https://${{RAILWAY_PUBLIC_DOMAIN}}/

# === Database ===
SYNAPSE_DB_USER=${{synapse-db.PGUSER}}
SYNAPSE_DB_PASSWORD=${{synapse-db.PGPASSWORD}}
SYNAPSE_DB_HOST=${{synapse-db.PGHOST}}
SYNAPSE_DB_PORT=${{synapse-db.PGPORT}}
SYNAPSE_DB_NAME=${{synapse-db.PGDATABASE}}

# === Secrets ===
SYNAPSE_REGISTRATION_SHARED_SECRET=<your-generated-secret>
SYNAPSE_MACAROON_SECRET_KEY=<your-generated-64-char-hex>
SYNAPSE_FORM_SECRET=<your-generated-64-char-hex>

# === Registration (DISABLED - use MAS) ===
SYNAPSE_ENABLE_REGISTRATION=false
SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=false

# === MAS OIDC ===
MAS_MATRIX_ENDPOINT=https://<mas-railway-url>
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<same-as-MAS-CLIENT_SECRET>
```

3. **Generate Public URL:**
   - Go to "Settings" tab
   - Click "Generate Domain"
   - Save this URL

4. **Update MAS Environment Variables:**
   - Go back to MAS service
   - Update `MAS_MATRIX_ENDPOINT` with Synapse's Railway URL
   - Update `MAS_MATRIX_SERVER_NAME` with Synapse's domain
   - Update `MAS_CLIENT_REDIRECT_URI` with Synapse's callback URL

### Step 5: Deploy Element Web Service

1. **Create Service:**
   - Click "+ New Service"
   - Select "GitHub Repo"
   - Same repository
   - Set root directory: `to-test-with-railway/element-web`

2. **Set Environment Variables:**

```bash
# === Element Configuration ===
ELEMENT_DEFAULT_HS=https://<synapse-railway-url>
ELEMENT_DEFAULT_SERVER_NAME=<synapse-railway-domain>
ELEMENT_DEFAULT_THEME=light
```

3. **Generate Public URL:**
   - Go to "Settings" tab
   - Click "Generate Domain"
   - This will be your Element Web URL

4. **Configure Port:**
   - Railway should auto-detect port 80 from nginx
   - If not, set PORT=80 in environment

## ✅ Verify Deployment

### 1. Check MAS
- Visit: `https://<mas-railway-url>`
- Should show MAS authentication page

### 2. Check Synapse
- Visit: `https://<synapse-railway-url>`
- Should show "It works! Synapse is running"

### 3. Check Element Web
- Visit: `https://<element-railway-url>`
- Should show Element login page
- Server should be pre-configured to your Synapse

### 4. Test OIDC Integration
```bash
curl https://<synapse-railway-url>/.well-known/matrix/client
```
Should return homeserver information.

## 🔄 Update Process

After initial deployment, if you need to update URLs:

1. **Update MAS Environment:**
   ```bash
   MAS_MATRIX_ENDPOINT=https://<new-synapse-url>
   ```

2. **Update Synapse Environment:**
   ```bash
   MAS_MATRIX_ENDPOINT=https://<new-mas-url>
   ```

3. **Redeploy both services**

## 📱 Testing with Element Desktop

1. Download Element Desktop: https://element.io/download
2. Configure custom server: `https://<synapse-railway-url>`
3. You'll be redirected to MAS for authentication
4. Register/Login through MAS
5. You'll be redirected back to Element

## 🔧 Environment Variables Reference

### Required for All Services

| Variable | Service | Description | Example |
|----------|---------|-------------|---------|
| `MAS_CLIENT_ID` | MAS, Synapse | OIDC Client ID (28+ chars) | `0000000000000000000SYNAPSE` |
| `MAS_CLIENT_SECRET` | MAS, Synapse | OIDC Client Secret (40+ chars) | Generated with `openssl rand -base64 32` |
| `MAS_ENCRYPTION_KEY` | MAS | Encryption key (64 hex chars) | Generated with `openssl rand -hex 32` |
| `SYNAPSE_MACAROON_SECRET_KEY` | Synapse | Macaroon secret (64 hex chars) | Generated with `openssl rand -hex 32` |
| `SYNAPSE_FORM_SECRET` | Synapse | Form secret (64 hex chars) | Generated with `openssl rand -hex 32` |

### Railway-Specific Variables

Railway provides these automatically:
- `${{RAILWAY_PUBLIC_DOMAIN}}` - Your service's public domain
- `${{DATABASE_URL}}` - PostgreSQL connection string
- `${{PGUSER}}`, `${{PGPASSWORD}}`, etc. - Database credentials

## 🐛 Troubleshooting

### MAS Can't Connect to Synapse
**Issue:** MAS shows connection errors to Synapse

**Fix:**
1. Verify `MAS_MATRIX_ENDPOINT` uses HTTPS and correct Railway URL
2. Check Synapse is deployed and running
3. Check Railway service logs

### Synapse OIDC Fails
**Issue:** "Invalid client" or "OIDC error"

**Fix:**
1. Verify `MAS_CLIENT_ID` and `MAS_CLIENT_SECRET` match in both services
2. Check `MAS_CLIENT_ID` is 28+ characters
3. Verify `MAS_MATRIX_ENDPOINT` in Synapse uses correct MAS URL
4. Check MAS is accessible from Synapse (internal Railway network)

### Element Can't Connect
**Issue:** Element shows "Unable to connect to homeserver"

**Fix:**
1. Verify `ELEMENT_DEFAULT_HS` uses correct Synapse Railway URL with HTTPS
2. Check Synapse is deployed and accessible
3. Test Synapse endpoint directly in browser

### Database Connection Errors
**Issue:** Service can't connect to PostgreSQL

**Fix:**
1. Verify Railway PostgreSQL service is running
2. Check environment variables use Railway's `${{database.VARIABLE}}` syntax
3. Ensure services are in the same Railway project

## 🔒 Security Checklist

- [ ] All secrets are unique and randomly generated
- [ ] `SYNAPSE_ENABLE_REGISTRATION=false` (use MAS only)
- [ ] HTTPS enabled (automatic on Railway)
- [ ] No `skip_verification` in production OIDC config
- [ ] Database passwords are strong
- [ ] MAS signing key is securely stored
- [ ] Don't commit secrets to Git

## 📚 Additional Resources

- [Railway Documentation](https://docs.railway.app)
- [Synapse Configuration](https://matrix-org.github.io/synapse/latest/)
- [MAS Documentation](https://github.com/matrix-org/matrix-authentication-service)
- [Element Documentation](https://element.io/help)

## 🎯 Next Steps

1. ✅ Deploy all services to Railway
2. ✅ Verify OIDC authentication works
3. ✅ Test user registration via MAS
4. ✅ Configure Element Desktop/Web
5. ✅ Set up custom domain (optional)
6. ✅ Configure email for MAS (optional)
7. ✅ Set up monitoring and backups

## 💾 Backup Strategy

**Database Backups:**
- Railway provides automatic PostgreSQL backups
- Go to Database service → Backups tab
- Configure backup retention

**Configuration Backup:**
- Keep all environment variables in a secure location
- Store MAS signing key securely
- Document all Railway URLs

---

**Your Matrix stack is ready for production! 🚀**
