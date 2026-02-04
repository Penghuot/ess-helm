# Railway Deployment Quick Start

## 🚀 Step-by-Step Deployment

### 1. Generate Secrets (Do this first!)

```bash
# Generate all secrets at once
echo "SYNAPSE_REGISTRATION_SHARED_SECRET=$(openssl rand -hex 32)"
echo "SYNAPSE_MACAROON_SECRET_KEY=$(openssl rand -hex 32)"
echo "SYNAPSE_FORM_SECRET=$(openssl rand -hex 32)"
echo "MAS_ENCRYPTION_KEY=$(openssl rand -hex 32)"
echo "MAS_CLIENT_SECRET=$(openssl rand -base64 32 | tr -d '\n')"

# Generate MAS signing key
openssl ecparam -name prime256v1 -genkey -noout -out mas-signing-railway.key
cat mas-signing-railway.key
```

**Save these outputs!** You'll paste them into Railway.

### 2. Create Railway Project

1. Go to https://railway.app/new
2. Click "Empty Project"
3. Name: `matrix-stack`

### 3. Add Databases

**Synapse DB:**
- Click "+ New"
- Database → PostgreSQL
- Name: `synapse-db`

**MAS DB:**
- Click "+ New"  
- Database → PostgreSQL
- Name: `mas-db`

### 4. Deploy MAS

1. **New Service:**
   - Click "+ New"
   - GitHub Repo → `ess-helm`
   - Root Directory: `to-test-with-railway/mas`

2. **Environment Variables:**
   ```bash
   MAS_PUBLIC_BASE=https://${{RAILWAY_PUBLIC_DOMAIN}}
   MAS_PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
   MAS_LISTEN_ADDR=0.0.0.0:8080
   MAS_DATABASE_URI=${{mas-db.DATABASE_URL}}
   MAS_MATRIX_ENDPOINT=https://TBD  # Update after Synapse deploy
   MAS_MATRIX_SERVER_NAME=TBD        # Update after Synapse deploy
   MAS_MATRIX_HOMESERVER=TBD         # Update after Synapse deploy
   MAS_MATRIX_SHARED_SECRET=<from-step-1>
   MAS_CLIENT_ID=0000000000000000000SYNAPSE
   MAS_CLIENT_SECRET=<from-step-1>
   MAS_CLIENT_REDIRECT_URI=https://TBD/_synapse/client/oidc/callback
   MAS_ENCRYPTION_KEY=<from-step-1>
   MAS_SIGNING_KEY=<paste-entire-pem-key>
   MAS_EMAIL_DOMAIN=example.com
   ```

3. **Generate Domain:**
   - Settings → Generate Domain
   - **Save this URL!** → `https://mas-xxxxx.up.railway.app`

### 5. Deploy Synapse

1. **New Service:**
   - Click "+ New"
   - GitHub Repo → `ess-helm`
   - Root Directory: `to-test-with-railway/synapse`

2. **Environment Variables:**
   ```bash
   SYNAPSE_SERVER_NAME=${{RAILWAY_PUBLIC_DOMAIN}}
   SYNAPSE_PUBLIC_BASEURL=https://${{RAILWAY_PUBLIC_DOMAIN}}/
   SYNAPSE_DB_USER=${{synapse-db.PGUSER}}
   SYNAPSE_DB_PASSWORD=${{synapse-db.PGPASSWORD}}
   SYNAPSE_DB_HOST=${{synapse-db.PGHOST}}
   SYNAPSE_DB_PORT=${{synapse-db.PGPORT}}
   SYNAPSE_DB_NAME=${{synapse-db.PGDATABASE}}
   SYNAPSE_REGISTRATION_SHARED_SECRET=<from-step-1>
   SYNAPSE_MACAROON_SECRET_KEY=<from-step-1>
   SYNAPSE_FORM_SECRET=<from-step-1>
   SYNAPSE_ENABLE_REGISTRATION=false
   SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=false
   MAS_MATRIX_ENDPOINT=<mas-url-from-step-4>
   MAS_CLIENT_ID=0000000000000000000SYNAPSE
   MAS_CLIENT_SECRET=<same-from-step-1>
   ```

3. **Generate Domain:**
   - Settings → Generate Domain
   - **Save this URL!** → `https://synapse-xxxxx.up.railway.app`

### 6. Update MAS URLs

Go back to MAS service and update:
```bash
MAS_MATRIX_ENDPOINT=https://synapse-xxxxx.up.railway.app
MAS_MATRIX_SERVER_NAME=synapse-xxxxx.up.railway.app
MAS_MATRIX_HOMESERVER=synapse-xxxxx.up.railway.app
MAS_CLIENT_REDIRECT_URI=https://synapse-xxxxx.up.railway.app/_synapse/client/oidc/callback
```

Click "Deploy" to restart MAS.

### 7. Deploy Element Web

1. **New Service:**
   - Click "+ New"
   - GitHub Repo → `ess-helm`
   - Root Directory: `to-test-with-railway/element-web`

2. **Environment Variables:**
   ```bash
   ELEMENT_DEFAULT_HS=https://synapse-xxxxx.up.railway.app
   ELEMENT_DEFAULT_SERVER_NAME=synapse-xxxxx.up.railway.app
   ELEMENT_DEFAULT_THEME=light
   ```

3. **Generate Domain:**
   - Settings → Generate Domain
   - This is your Element Web URL

## ✅ Verification

1. **Test MAS:** Visit `https://mas-xxxxx.up.railway.app`
   - Should show authentication page

2. **Test Synapse:** Visit `https://synapse-xxxxx.up.railway.app`
   - Should show "It works! Synapse is running"

3. **Test Element:** Visit `https://element-xxxxx.up.railway.app`
   - Should show Element interface
   - Try to login → will redirect to MAS

## 🎯 Test Registration

1. Open Element Web (your Railway URL)
2. Click "Create Account"
3. You'll be redirected to MAS
4. Register on MAS
5. You'll be redirected back to Element
6. Start chatting!

## 📋 Checklist

- [ ] All secrets generated and saved
- [ ] MAS deployed with correct database
- [ ] Synapse deployed with correct database
- [ ] MAS environment updated with Synapse URLs
- [ ] Element Web deployed
- [ ] MAS accessible (test in browser)
- [ ] Synapse accessible (test in browser)
- [ ] Element Web accessible (test in browser)
- [ ] Registration test successful
- [ ] Element Desktop configured (optional)

## 🐛 Quick Troubleshooting

**Service won't start:**
- Check logs in Railway dashboard
- Verify all environment variables are set
- Check DATABASE_URL is correct

**OIDC fails:**
- Verify MAS_CLIENT_ID and MAS_CLIENT_SECRET match in both services
- Check MAS_MATRIX_ENDPOINT URLs are correct
- Check MAS_CLIENT_REDIRECT_URI is correct

**Can't register:**
- Verify SYNAPSE_ENABLE_REGISTRATION=false
- Check MAS service is accessible
- Check MAS logs for errors

## 📚 Full Documentation

See `RAILWAY-DEPLOYMENT.md` for complete documentation.

---

**Deployment time:** ~15 minutes
**Cost:** Railway free tier includes $5/month credit
