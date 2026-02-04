# 🎯 SECRETS CHEAT SHEET - COPY THIS TO NOTEPAD

## Step 1: Run This PowerShell Script

```powershell
Write-Host "`n=== COPY EVERYTHING BELOW ===" -ForegroundColor Green
Write-Host ""

# 1. Synapse Macaroon Secret
$macaroon = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "1. SYNAPSE_MACAROON_SECRET_KEY=$macaroon"

# 2. Synapse Form Secret
$form = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "2. SYNAPSE_FORM_SECRET=$form"

# 3. MAS-Synapse Shared Secret
$shared = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "3. MAS_MATRIX_SHARED_SECRET=$shared"

# 4. MAS Client Secret
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$client = [Convert]::ToBase64String($bytes)
Write-Host "4. MAS_CLIENT_SECRET=$client"

# 5. MAS Encryption Key
$encryption = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
Write-Host "5. MAS_ENCRYPTION_KEY=$encryption"

Write-Host ""
Write-Host "=== SAVE TO NOTEPAD ===" -ForegroundColor Green
```

**Copy the output to Notepad. You'll have 5 lines numbered 1-5.**

---

## Step 2: Generate MAS Signing Key

```powershell
openssl ecparam -name prime256v1 -genkey -noout -out mas-signing.key
Get-Content mas-signing.key
```

**Copy the ENTIRE PEM key** (starts with `-----BEGIN EC PRIVATE KEY-----`)

---

## 📋 COPY-PASTE BLOCKS FOR RAILWAY

### ═══════════════════════════════════════════════════
### MAS SERVICE - Environment Variables
### ═══════════════════════════════════════════════════

**Paste this into Railway MAS service variables:**

```
MAS_PUBLIC_BASE=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_LISTEN_ADDR=0.0.0.0:8080
MAS_DATABASE_URI=${{mas-db.DATABASE_URL}}
MAS_MATRIX_ENDPOINT=TEMPORARY
MAS_MATRIX_SERVER_NAME=TEMPORARY
MAS_MATRIX_HOMESERVER=TEMPORARY
MAS_MATRIX_SHARED_SECRET=<PASTE_SECRET_3_HERE>
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<PASTE_SECRET_4_HERE>
MAS_CLIENT_REDIRECT_URI=TEMPORARY
MAS_ENCRYPTION_KEY=<PASTE_SECRET_5_HERE>
MAS_SIGNING_KEY=<PASTE_ENTIRE_PEM_KEY_HERE>
MAS_EMAIL_DOMAIN=matrix.local
MAS_PUBLIC_BASE=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
MAS_LISTEN_ADDR=0.0.0.0:8080
MAS_DATABASE_URI=${{mas-db.DATABASE_URL}}
MAS_MATRIX_ENDPOINT=TEMPORARY
MAS_MATRIX_SERVER_NAME=TEMPORARY
MAS_MATRIX_HOMESERVER=TEMPORARY
MAS_MATRIX_SHARED_SECRET="95946d21b1ae4cf8aef0c801b44dd35226d7a5f1ca500c08563151e128a89398"
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET="7XG6t2DaxVLtk81T3JaPRO9c3GBsfhapSutjnn/ieGE="
MAS_CLIENT_REDIRECT_URI=TEMPORARY
MAS_ENCRYPTION_KEY="e30ced82286c06d0d873277811e4d004afb200744080969cad9cebbbda4d0149"
MAS_SIGNING_KEY="-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIEESHxOh58JxiSsc7ripo/f0CxpLy36M9tJWnJmI4YvjoAoGCCqGSM49
AwEHoUQDQgAE3LPKIHA2pk8I2qUMlPjLEUPIhPDmXYyFm3GrHIqb19eM0cEvC7Er
TOBezK7hdwfArnRhMrqeyY2KZAMB0g5oSw==
-----END EC PRIVATE KEY-----
"
MAS_EMAIL_DOMAIN=matrix.local
```

**What to replace:**
- `<PASTE_SECRET_3_HERE>` → Paste line 3 from Notepad (MAS_MATRIX_SHARED_SECRET)
- `<PASTE_SECRET_4_HERE>` → Paste line 4 from Notepad (MAS_CLIENT_SECRET)
- `<PASTE_SECRET_5_HERE>` → Paste line 5 from Notepad (MAS_ENCRYPTION_KEY)
- `<PASTE_ENTIRE_PEM_KEY_HERE>` → Paste entire PEM key including headers

**Leave TEMPORARY values as-is for now!**

---

### ═══════════════════════════════════════════════════
### SYNAPSE SERVICE - Environment Variables
### ═══════════════════════════════════════════════════

**Paste this into Railway Synapse service variables:**

```
SYNAPSE_SERVER_NAME=${{RAILWAY_PUBLIC_DOMAIN}}
SYNAPSE_PUBLIC_BASEURL=https://${{RAILWAY_PUBLIC_DOMAIN}}/
SYNAPSE_DB_USER=${{synapse-db.PGUSER}}
SYNAPSE_DB_PASSWORD=${{synapse-db.PGPASSWORD}}
SYNAPSE_DB_HOST=${{synapse-db.PGHOST}}
SYNAPSE_DB_PORT=${{synapse-db.PGPORT}}
SYNAPSE_DB_NAME=${{synapse-db.PGDATABASE}}
SYNAPSE_MACAROON_SECRET_KEY=<PASTE_SECRET_1_HERE>
SYNAPSE_FORM_SECRET=<PASTE_SECRET_2_HERE>
MAS_MATRIX_ENDPOINT=<PASTE_MAS_URL_HERE>
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=<PASTE_SECRET_4_HERE>
MAS_MATRIX_SHARED_SECRET=<PASTE_SECRET_3_HERE>

SYNAPSE_SERVER_NAME=${{RAILWAY_PUBLIC_DOMAIN}}
SYNAPSE_PUBLIC_BASEURL=https://${{RAILWAY_PUBLIC_DOMAIN}}/
SYNAPSE_DB_USER=${{synapse-db.PGUSER}}
SYNAPSE_DB_PASSWORD=${{synapse-db.PGPASSWORD}}
SYNAPSE_DB_HOST=${{synapse-db.PGHOST}}
SYNAPSE_DB_PORT=${{synapse-db.PGPORT}}
SYNAPSE_DB_NAME=${{synapse-db.PGDATABASE}}
SYNAPSE_MACAROON_SECRET_KEY="8f8f25f9a17fa9a7b495f8e8f44b9344ca47081f5defb0416b57b241c5d56284"
SYNAPSE_FORM_SECRET="574308507c1054af6354fcfe02d580120f01349e5b5abd6e0194e69beb531983"
MAS_MATRIX_ENDPOINT="https://mas-service-production-6c0a.up.railway.app"
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET="7XG6t2DaxVLtk81T3JaPRO9c3GBsfhapSutjnn/ieGE="
MAS_MATRIX_SHARED_SECRET="95946d21b1ae4cf8aef0c801b44dd35226d7a5f1ca500c08563151e128a89398"
```

**What to replace:**
- `<PASTE_SECRET_1_HERE>` → Paste line 1 from Notepad (SYNAPSE_MACAROON_SECRET_KEY)
- `<PASTE_SECRET_2_HERE>` → Paste line 2 from Notepad (SYNAPSE_FORM_SECRET)
- `<PASTE_SECRET_3_HERE>` → Paste line 3 from Notepad (MAS_MATRIX_SHARED_SECRET)
- `<PASTE_SECRET_4_HERE>` → Paste line 4 from Notepad (MAS_CLIENT_SECRET)
- `<PASTE_MAS_URL_HERE>` → Paste MAS URL from Railway (e.g., `https://mas-production-abc123.up.railway.app`)

---

### ═══════════════════════════════════════════════════
### MAS UPDATE (After Synapse deploys)
### ═══════════════════════════════════════════════════

**Go back to MAS service, edit these 4 variables:**

**✅ YOUR ACTUAL VALUES - COPY THIS BLOCK:**

```
MAS_MATRIX_ENDPOINT=https://synapse-production-7433.up.railway.app
MAS_MATRIX_SERVER_NAME=synapse-production-7433.up.railway.app
MAS_MATRIX_HOMESERVER=synapse-production-7433.up.railway.app
MAS_CLIENT_REDIRECT_URI=https://synapse-production-7433.up.railway.app/_synapse/client/oidc/callback
```

---

### ═══════════════════════════════════════════════════
### ELEMENT WEB SERVICE - Environment Variables
### ═══════════════════════════════════════════════════

**✅ YOUR ACTUAL VALUES - COPY THIS BLOCK:**

```
ELEMENT_DEFAULT_HS=https://synapse-production-7433.up.railway.app
ELEMENT_DEFAULT_SERVER_NAME=synapse-production-7433.up.railway.app
ELEMENT_BRAND=RMSS
```

---

## 🗺️ VISUAL GUIDE - Where Each Secret Goes

```
┌─────────────────────────────────────────────────────────────┐
│  SECRET 1: SYNAPSE_MACAROON_SECRET_KEY                      │
│  Used by: Synapse                                           │
│  Purpose: Session tokens                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SECRET 2: SYNAPSE_FORM_SECRET                              │
│  Used by: Synapse                                           │
│  Purpose: Form validation                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SECRET 3: MAS_MATRIX_SHARED_SECRET                         │
│  Used by: BOTH MAS and Synapse                              │
│  Purpose: Communication between MAS and Synapse             │
│  ⚠️ IMPORTANT: Must be identical in both services!          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SECRET 4: MAS_CLIENT_SECRET                                │
│  Used by: BOTH MAS and Synapse                              │
│  Purpose: OAuth2 client authentication                      │
│  ⚠️ IMPORTANT: Must be identical in both services!          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SECRET 5: MAS_ENCRYPTION_KEY                               │
│  Used by: MAS                                               │
│  Purpose: Encrypt MAS database data                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  PEM KEY: MAS_SIGNING_KEY                                   │
│  Used by: MAS                                               │
│  Purpose: Sign OAuth2 tokens (JWT)                          │
│  ⚠️ Must include -----BEGIN and -----END lines              │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ QUICK CHECKLIST

**Before deploying MAS:**
- [ ] Generated all 5 secrets with PowerShell
- [ ] Generated PEM signing key with OpenSSL
- [ ] Saved all to Notepad
- [ ] Created synapse-db and mas-db in Railway

**Before deploying Synapse:**
- [ ] MAS is deployed and green
- [ ] MAS domain generated and copied
- [ ] Have all secrets in Notepad

**Before updating MAS:**
- [ ] Synapse is deployed and green
- [ ] Synapse domain generated and copied

**Before deploying Element:**
- [ ] MAS updated with Synapse URL
- [ ] Synapse domain copied

---

## 🎯 COMPLETE EXAMPLE (With Fake Values)

**After running PowerShell script, your Notepad should look like:**

```
1. SYNAPSE_MACAROON_SECRET_KEY=a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6abcd
2. SYNAPSE_FORM_SECRET=1a2b3c4d5e6f1a2b3c4d5e6f1a2b3c4d5e6f1a2b3c4d5e6f1a2b3c4d5e6f1234
3. MAS_MATRIX_SHARED_SECRET=9z8y7x6w5v4u9z8y7x6w5v4u9z8y7x6w5v4u9z8y7x6w5v4u9z8y7x6w5v4u9876
4. MAS_CLIENT_SECRET=Zm9vYmFyYmF6cXV4Zm9vYmFyYmF6cXV4Zm9vYmFyYg==
5. MAS_ENCRYPTION_KEY=f1e2d3c4b5a6f1e2d3c4b5a6f1e2d3c4b5a6f1e2d3c4b5a6f1e2d3c4b5a6fedc
```

**And your PEM key:**

```
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIFoobarExampleKeyContent...
...more lines...
-----END EC PRIVATE KEY-----
```

---

**NOW YOU HAVE EVERYTHING YOU NEED! GO TO [EASY-DEPLOY.md](EASY-DEPLOY.md) AND START DEPLOYING! 🚀**
