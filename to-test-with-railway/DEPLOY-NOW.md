# 🚀 DEPLOY TO RAILWAY NOW - Presentation Ready

**Time to complete: 20-30 minutes**

## ⚡ PART 1: Generate All Secrets (5 minutes)

Open PowerShell and run these commands **one by one**. Copy each output to a text file.

### Required Secrets:

```powershell
# 1. Synapse Macaroon Secret
$macaroon = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
Write-Host "SYNAPSE_MACAROON_SECRET_KEY=$macaroon"

# 2. Synapse Form Secret
$form = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
Write-Host "SYNAPSE_FORM_SECRET=$form"

# 3. MAS-Synapse Shared Secret
$shared = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
Write-Host "MAS_MATRIX_SHARED_SECRET=$shared"

# 4. MAS Client Secret
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$client = [Convert]::ToBase64String($bytes)
Write-Host "MAS_CLIENT_SECRET=$client"

# 5. MAS Encryption Key
$encryption = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
Write-Host "MAS_ENCRYPTION_KEY=$encryption"

# 6. LiveKit API Key
$lk_key = -join ((1..16) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
Write-Host "LIVEKIT_API_KEY=APIKey$lk_key"

# 7. LiveKit API Secret
$lk_secret = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
Write-Host "LIVEKIT_API_SECRET=$lk_secret"
```

### Generate MAS Signing Key:

```powershell
# Install OpenSSL if needed (or use Git Bash)
# For Windows: Download from https://slproweb.com/products/Win32OpenSSL.html

# Generate the key
openssl ecparam -name prime256v1 -genkey -noout -out mas-signing.key

# View the key (copy entire content)
Get-Content mas-signing.key
```

**📋 Copy all outputs to a text file named `railway-secrets.txt`**

---

## 🏗️ PART 2: Railway Setup (15 minutes)

### Step 1: Create Project (1 min)

1. Go to https://railway.app
2. Click **"New Project"**
3. Select **"Empty Project"**
4. Name it: `matrix-stack`

---

### Step 2: Add PostgreSQL Databases (2 min)

**Database 1 - Synapse:**
1. Click **"+ New"** → **"Database"** → **"PostgreSQL"**
2. Name: `synapse-db`
3. Wait for it to deploy (green checkmark)

**Database 2 - MAS:**
1. Click **"+ New"** → **"Database"** → **"PostgreSQL"**
2. Name: `mas-db`
3. Wait for it to deploy (green checkmark)

---

### Step 3: Deploy MAS (5 min)

1. Click **"+ New"** → **"GitHub Repo"**
2. Connect your GitHub account if needed
3. Select repository: `element-hq/ess-helm` (or your fork)
4. **Root Directory:** `to-test-with-railway/mas`
5. Click **"Add variables"**

**MAS Environment Variables:**

```bash
MAS_PUBLIC_BASE=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_LISTEN_ADDR=0.0.0.0:8080
MAS_DATABASE_URI=${{mas-db.DATABASE_URL}}
MAS_MATRIX_ENDPOINT=TEMPORARY
MAS_MATRIX_SERVER_NAME=TEMPORARY
MAS_MATRIX_HOMESERVER=TEMPORARY
MAS_MATRIX_SHARED_SECRET=<paste-from-part1-step3>
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<paste-from-part1-step4>
MAS_CLIENT_REDIRECT_URI=TEMPORARY
MAS_ENCRYPTION_KEY=<paste-from-part1-step5>
MAS_SIGNING_KEY=<paste-entire-pem-key-from-part1>
MAS_EMAIL_DOMAIN=matrix.local
```

6. Click **"Deploy"**
7. Wait for deployment (this takes ~3 minutes)
8. Go to **"Settings"** → **"Networking"** → **"Generate Domain"**
9. **📋 COPY THIS URL** → `https://mas-production-xxxx.up.railway.app`

---

### Step 4: Deploy Synapse (5 min)

1. Click **"+ New"** → **"GitHub Repo"**
2. Select same repository
3. **Root Directory:** `to-test-with-railway/synapse`
4. Click **"Add variables"**

**Synapse Environment Variables:**

```bash
SYNAPSE_SERVER_NAME=${{RAILWAY_PUBLIC_DOMAIN}}
SYNAPSE_PUBLIC_BASEURL=https://${{RAILWAY_PUBLIC_DOMAIN}}/
SYNAPSE_DB_USER=${{synapse-db.PGUSER}}
SYNAPSE_DB_PASSWORD=${{synapse-db.PGPASSWORD}}
SYNAPSE_DB_HOST=${{synapse-db.PGHOST}}
SYNAPSE_DB_PORT=${{synapse-db.PGPORT}}
SYNAPSE_DB_NAME=${{synapse-db.PGDATABASE}}
SYNAPSE_MACAROON_SECRET_KEY=<paste-from-part1-step1>
SYNAPSE_FORM_SECRET=<paste-from-part1-step2>
MAS_MATRIX_ENDPOINT=<paste-mas-url-from-step3>
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<paste-from-part1-step4>
MAS_MATRIX_SHARED_SECRET=<paste-from-part1-step3>
```

5. Click **"Deploy"**
6. Wait for deployment (~4 minutes, database migration takes time)
7. Go to **"Settings"** → **"Networking"** → **"Generate Domain"**
8. **📋 COPY THIS URL** → `https://synapse-production-xxxx.up.railway.app`

---

### Step 5: Update MAS with Synapse URL (1 min)

1. Go back to **MAS service**
2. Click **"Variables"**
3. Update these 4 variables:

```bash
MAS_MATRIX_ENDPOINT=<paste-synapse-url>
MAS_MATRIX_SERVER_NAME=<synapse-domain-without-https>
MAS_MATRIX_HOMESERVER=<synapse-domain-without-https>
MAS_CLIENT_REDIRECT_URI=<synapse-url>/_synapse/client/oidc/callback
```

Example:
```bash
MAS_MATRIX_ENDPOINT=https://synapse-production-abc123.up.railway.app
MAS_MATRIX_SERVER_NAME=synapse-production-abc123.up.railway.app
MAS_MATRIX_HOMESERVER=synapse-production-abc123.up.railway.app
MAS_CLIENT_REDIRECT_URI=https://synapse-production-abc123.up.railway.app/_synapse/client/oidc/callback
```

4. MAS will automatically restart

---

### Step 6: Deploy Element Web (2 min)

1. Click **"+ New"** → **"GitHub Repo"**
2. Select same repository
3. **Root Directory:** `to-test-with-railway/element-web`
4. Click **"Add variables"**

**Element Web Environment Variables:**

```bash
ELEMENT_DEFAULT_HS=<paste-synapse-url>
ELEMENT_DEFAULT_SERVER_NAME=<synapse-domain-without-https>
ELEMENT_BRAND=RMSS
```

5. Click **"Deploy"**
6. Wait for deployment (~2 minutes)
7. Go to **"Settings"** → **"Networking"** → **"Generate Domain"**
8. **📋 COPY THIS URL** → `https://element-production-xxxx.up.railway.app`

---

## ✅ PART 3: Test Everything (5 minutes)

### Test 1: MAS Health Check
Visit: `https://mas-production-xxxx.up.railway.app/.well-known/openid-configuration`

**Expected:** JSON response with OAuth2 configuration

### Test 2: Synapse Health Check
Visit: `https://synapse-production-xxxx.up.railway.app/_matrix/client/versions`

**Expected:** JSON response like:
```json
{
  "versions": ["r0.0.1", "r0.1.0", ...]
}
```

### Test 3: Element Web
Visit: `https://element-production-xxxx.up.railway.app`

**Expected:** Element login screen

### Test 4: Registration Flow (IMPORTANT!)

1. On Element Web, click **"Create Account"**
2. You'll be redirected to MAS
3. Fill in:
   - Username: `testuser`
   - Password: `TestPassword123!`
4. Click **"Register"**
5. You'll be redirected back to Element
6. You should be logged in! ✅

---

## 🎯 PART 4: Presentation Demo (Tomorrow)

### Demo Script for Your Supervisor:

**1. Show Architecture (2 min)**
```
"We deployed the Matrix Stack with 4 components:
- Synapse: Matrix homeserver
- MAS: Authentication service (MSC3861)
- Element Web: User interface
- 2 PostgreSQL databases

All running on Railway with auto-scaling."
```

**2. Show Working Services (1 min)**
- Open MAS URL → "This is the authentication service"
- Open Synapse URL → "This is the Matrix API"
- Open Element URL → "This is the client interface"

**3. Live Registration Demo (3 min)**
1. Open Element Web
2. Click "Create Account"
3. Register a new user live
4. Show successful login
5. Create a room
6. Send a message

**4. Show Railway Dashboard (2 min)**
- Show all services running (green checkmarks)
- Show logs (click any service → "Logs")
- Show environment variables
- Show auto-generated domains

**5. Highlight Key Features:**
- ✅ No email verification required (fast registration)
- ✅ Secure OAuth2 flow (MAS → Synapse)
- ✅ Production-ready PostgreSQL
- ✅ Auto-scaling infrastructure
- ✅ HTTPS by default
- ✅ Easy to monitor and maintain

---

## 🆘 Troubleshooting

### Issue: Synapse won't start
**Solution:** Check environment variables, especially database connection. Go to Synapse → Logs → look for database errors.

### Issue: MAS won't start
**Solution:** Check `MAS_SIGNING_KEY` is complete PEM format (starts with `-----BEGIN EC PRIVATE KEY-----`)

### Issue: Can't register
**Solution:** 
1. Check MAS logs: Click MAS service → Logs
2. Verify `MAS_CLIENT_REDIRECT_URI` matches Synapse URL exactly
3. Try redeploying MAS

### Issue: Element shows "Can't reach homeserver"
**Solution:** Verify `ELEMENT_DEFAULT_HS` points to correct Synapse URL

---

## 📋 Pre-Presentation Checklist

- [ ] All 4 services show green checkmark
- [ ] Can access MAS at `/.well-known/openid-configuration`
- [ ] Can access Synapse at `/_matrix/client/versions`
- [ ] Can access Element Web homepage
- [ ] Successfully registered a test user
- [ ] Test user can create a room
- [ ] Test user can send messages
- [ ] Have Railway dashboard open in browser tab
- [ ] Have Element Web open in browser tab
- [ ] Know all your URLs by heart

---

## 🎓 Key Points for Supervisor

**Technical Achievements:**
- Deployed full Matrix stack in production
- Integrated MSC3861 (next-gen Matrix auth)
- Configured OAuth2 flow correctly
- Used infrastructure-as-code (Dockerfiles, configs)
- Followed Matrix security best practices

**Production Readiness:**
- Separate databases for each service
- Environment-based configuration
- Health checks on all services
- Secure secret management
- Auto-scaling infrastructure

**Cost Efficiency:**
- Free tier on Railway ($5 credit/month)
- Pay-as-you-grow model
- No server maintenance overhead

---

## 📞 Last-Minute Help

If anything breaks during deployment, check:
1. **Railway Logs** - Click service → "Logs" tab
2. **Environment Variables** - Click service → "Variables" tab
3. **Domain URLs** - Make sure you copied them correctly

**Emergency contacts:**
- Railway Status: https://railway.statuspage.io
- Matrix Spec: https://spec.matrix.org

---

## 🎉 Success Criteria

You're ready when:
- ✅ All services are green in Railway
- ✅ You can register a user through Element
- ✅ The registered user can send messages
- ✅ You can explain the architecture
- ✅ You know where to check logs

**Good luck with your presentation! 🚀**
