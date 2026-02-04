# 🚀 LAZY DEPLOYMENT - JUST COPY & PASTE!

**No thinking required. Just follow the boxes!**

---

## STEP 1: Generate ALL Secrets (ONE TIME ONLY)

**Copy this ENTIRE block** and paste into PowerShell:

```powershell
Write-Host "`n=== COPY EVERYTHING BELOW THIS LINE ===" -ForegroundColor Green
Write-Host ""

# Macaroon Secret
$macaroon = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "SYNAPSE_MACAROON_SECRET_KEY=$macaroon"

# Form Secret
$form = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "SYNAPSE_FORM_SECRET=$form"

# MAS-Synapse Shared Secret
$shared = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "MAS_MATRIX_SHARED_SECRET=$shared"

# MAS Client Secret
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$client = [Convert]::ToBase64String($bytes)
Write-Host "MAS_CLIENT_SECRET=$client"

# MAS Encryption Key
$encryption = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "MAS_ENCRYPTION_KEY=$encryption"

Write-Host ""
Write-Host "=== SAVE THE ABOVE TO NOTEPAD ===" -ForegroundColor Green
Write-Host ""
```

**Save the output to Notepad!** You'll need these values.

---

## STEP 2: Generate MAS Signing Key

**Copy this** and paste into PowerShell (or Git Bash):

```powershell
openssl ecparam -name prime256v1 -genkey -noout -out mas-signing.key
Get-Content mas-signing.key
```

**Copy the ENTIRE output** (including `-----BEGIN` and `-----END` lines) to Notepad.

---

## STEP 3: Create Railway Project

1. Go to https://railway.app/new
2. Click **"Empty Project"**
3. Name: `matrix-stack`

---

## STEP 4: Add Databases

**Database 1:**
- Click **"+ New"** → **"Database"** → **"PostgreSQL"**
- Name: `synapse-db`
- Wait for green ✅

**Database 2:**
- Click **"+ New"** → **"Database"** → **"PostgreSQL"**
- Name: `mas-db`
- Wait for green ✅

---

## STEP 5: Deploy MAS Service

1. Click **"+ New"** → **"GitHub Repo"**
2. Select: `element-hq/ess-helm` (or your fork)
3. **Root Directory:** `to-test-with-railway/mas`
4. Click **"Add Variables"**

### 📋 COPY-PASTE THIS ENTIRE BLOCK:

```
MAS_PUBLIC_BASE=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_LISTEN_ADDR=0.0.0.0:8080
MAS_DATABASE_URI=${{mas-db.DATABASE_URL}}
MAS_MATRIX_ENDPOINT=TEMPORARY
MAS_MATRIX_SERVER_NAME=TEMPORARY
MAS_MATRIX_HOMESERVER=TEMPORARY
MAS_MATRIX_SHARED_SECRET=PASTE_FROM_STEP1
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=PASTE_FROM_STEP1
MAS_CLIENT_REDIRECT_URI=TEMPORARY
MAS_ENCRYPTION_KEY=PASTE_FROM_STEP1
MAS_SIGNING_KEY=PASTE_FROM_STEP2
MAS_EMAIL_DOMAIN=matrix.local
```

**Now replace these:**
- Replace `PASTE_FROM_STEP1` with your generated secrets (3 places)
- Replace `PASTE_FROM_STEP2` with your PEM key (paste entire key including headers)

5. Click **"Deploy"**
6. Wait 3 minutes for green ✅
7. Go to **Settings** → **Networking** → Click **"Generate Domain"**
8. **📋 COPY THIS URL** (like `https://mas-production-abc123.up.railway.app`)

---

## STEP 6: Deploy Synapse Service

1. Click **"+ New"** → **"GitHub Repo"**
2. Select: `element-hq/ess-helm`
3. **Root Directory:** `to-test-with-railway/synapse`
4. Click **"Add Variables"**

### 📋 COPY-PASTE THIS ENTIRE BLOCK:

```
SYNAPSE_SERVER_NAME=${{RAILWAY_PUBLIC_DOMAIN}}
SYNAPSE_PUBLIC_BASEURL=https://${{RAILWAY_PUBLIC_DOMAIN}}/
SYNAPSE_DB_USER=${{synapse-db.PGUSER}}
SYNAPSE_DB_PASSWORD=${{synapse-db.PGPASSWORD}}
SYNAPSE_DB_HOST=${{synapse-db.PGHOST}}
SYNAPSE_DB_PORT=${{synapse-db.PGPORT}}
SYNAPSE_DB_NAME=${{synapse-db.PGDATABASE}}
SYNAPSE_MACAROON_SECRET_KEY=PASTE_FROM_STEP1
SYNAPSE_FORM_SECRET=PASTE_FROM_STEP1
MAS_MATRIX_ENDPOINT=PASTE_MAS_URL_FROM_STEP5
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=PASTE_FROM_STEP1
MAS_MATRIX_SHARED_SECRET=PASTE_FROM_STEP1
```

**Now replace these:**
- Replace `PASTE_FROM_STEP1` with secrets (4 places - check Notepad for which is which)
- Replace `PASTE_MAS_URL_FROM_STEP5` with the MAS URL you copied

5. Click **"Deploy"**
6. Wait 4 minutes (database migration takes time)
7. Go to **Settings** → **Networking** → Click **"Generate Domain"**
8. **📋 COPY THIS URL** (like `https://synapse-production-xyz789.up.railway.app`)

---

## STEP 7: Update MAS with Synapse URL

1. Go back to **MAS service** in Railway
2. Click **"Variables"** tab
3. Find these 4 variables and update them:

**Update these 4 variables to match Synapse URL:**

```
MAS_MATRIX_ENDPOINT=PASTE_SYNAPSE_URL_HERE
MAS_MATRIX_SERVER_NAME=PASTE_SYNAPSE_DOMAIN_ONLY_HERE
MAS_MATRIX_HOMESERVER=PASTE_SYNAPSE_DOMAIN_ONLY_HERE
MAS_CLIENT_REDIRECT_URI=PASTE_SYNAPSE_URL_HERE/_synapse/client/oidc/callback
```

**Example (if Synapse URL is `https://synapse-production-xyz789.up.railway.app`):**

```
MAS_MATRIX_ENDPOINT=https://synapse-production-xyz789.up.railway.app
MAS_MATRIX_SERVER_NAME=synapse-production-xyz789.up.railway.app
MAS_MATRIX_HOMESERVER=synapse-production-xyz789.up.railway.app
MAS_CLIENT_REDIRECT_URI=https://synapse-production-xyz789.up.railway.app/_synapse/client/oidc/callback
```

4. MAS will automatically restart (wait 1 minute)

---

## STEP 8: Deploy Element Web

1. Click **"+ New"** → **"GitHub Repo"**
2. Select: `element-hq/ess-helm`
3. **Root Directory:** `to-test-with-railway/element-web`
4. Click **"Add Variables"**

### 📋 COPY-PASTE THIS ENTIRE BLOCK:

```
ELEMENT_DEFAULT_HS=PASTE_SYNAPSE_URL_HERE
ELEMENT_DEFAULT_SERVER_NAME=PASTE_SYNAPSE_DOMAIN_ONLY_HERE
ELEMENT_BRAND=RMSS
```

**Example (if Synapse URL is `https://synapse-production-xyz789.up.railway.app`):**

```
ELEMENT_DEFAULT_HS=https://synapse-production-xyz789.up.railway.app
ELEMENT_DEFAULT_SERVER_NAME=synapse-production-xyz789.up.railway.app
ELEMENT_BRAND=RMSS
```

5. Click **"Deploy"**
6. Wait 2 minutes
7. Go to **Settings** → **Networking** → Click **"Generate Domain"**
8. **📋 COPY THIS URL** (like `https://element-production-def456.up.railway.app`)

---

## ✅ STEP 9: Test Everything

### Test 1: Open MAS
Visit: `https://mas-production-YOUR-DOMAIN.up.railway.app/.well-known/openid-configuration`

**Should see:** JSON with OAuth2 config

### Test 2: Open Synapse
Visit: `https://synapse-production-YOUR-DOMAIN.up.railway.app/_matrix/client/versions`

**Should see:** JSON with version numbers

### Test 3: Open Element
Visit: `https://element-production-YOUR-DOMAIN.up.railway.app`

**Should see:** Element login page

### Test 4: Register User (IMPORTANT!)

1. On Element, click **"Create Account"**
2. You'll be redirected to MAS
3. Register:
   - Username: `testuser`
   - Password: `TestPassword123!`
4. Click **"Register"**
5. You'll be redirected back to Element
6. **You're logged in!** ✅

---

## 🎯 YOU'RE DONE!

**All services running:**
- ✅ MAS (authentication)
- ✅ Synapse (Matrix server)
- ✅ Element Web (client)
- ✅ 2 PostgreSQL databases

**What you can do now:**
- Create rooms
- Send messages
- Register more users
- Show your supervisor!

---

## 📋 Quick Reference (Save These URLs)

```
MAS:      https://mas-production-_________.up.railway.app
Synapse:  https://synapse-production-_________.up.railway.app
Element:  https://element-production-_________.up.railway.app
Railway:  https://railway.app/project/YOUR-PROJECT
```

---

## 🆘 If Something Breaks

**Service won't start?**
1. Click the service in Railway
2. Go to **"Logs"** tab
3. Look for the error message
4. Check if you pasted the secrets correctly

**Can't register?**
1. Check MAS logs
2. Make sure `MAS_CLIENT_REDIRECT_URI` includes the full Synapse URL + `/_synapse/client/oidc/callback`

**Element shows error?**
1. Check Element logs
2. Make sure `ELEMENT_DEFAULT_HS` points to Synapse URL with `https://`

---

## 💪 Presentation Tomorrow

**Demo Script:**
1. Open Railway dashboard (show all green)
2. Open Element Web
3. Click "Create Account"
4. Register live (use `demo_[time]` as username)
5. Send a message
6. Show Railway logs

**Key Points:**
- "Full Matrix stack in 20 minutes"
- "OAuth2 authentication with MSC3861"
- "Production-ready with auto-scaling"
- "Costs $5/month (free tier)"

---

**That's it! No thinking, just copy-paste! 🚀**
