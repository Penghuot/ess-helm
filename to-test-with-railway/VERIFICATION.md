# 🔍 Railway Deployment - Final Verification Checklist

## Before Your Presentation - Run This Test!

### Step 1: Check All Services Are Running

Go to Railway dashboard: https://railway.app/project/matrix-stack

**Expected Status:**
- ✅ synapse-db: Running (green)
- ✅ mas-db: Running (green)  
- ✅ mas: Running (green)
- ✅ synapse: Running (green)
- ✅ element-web: Running (green)

**If any service is red/crashed:**
1. Click the service
2. Go to "Logs" tab
3. Look for error messages
4. Common issues below ⬇️

---

## Step 2: Test Each Endpoint

### Test MAS (Authentication Service)

**URL:** `https://mas-production-xxxx.up.railway.app/.well-known/openid-configuration`

**Expected Response:**
```json
{
  "issuer": "https://mas-production-xxxx.up.railway.app",
  "authorization_endpoint": "https://...",
  "token_endpoint": "https://...",
  ...
}
```

**If you get 404 or error:**
- Check MAS logs in Railway
- Verify `MAS_PUBLIC_BASE` is set correctly
- Verify `MAS_DATABASE_URI` points to mas-db

---

### Test Synapse (Matrix Homeserver)

**URL:** `https://synapse-production-xxxx.up.railway.app/_matrix/client/versions`

**Expected Response:**
```json
{
  "versions": [
    "r0.0.1",
    "r0.1.0",
    "r0.2.0",
    ...
  ]
}
```

**If you get error:**
- Check Synapse logs
- Look for database connection errors
- Verify all database variables are set

---

### Test Element Web

**URL:** `https://element-production-xxxx.up.railway.app`

**Expected:**
- Should see Element login screen
- Should show "Sign In" and "Create Account" buttons

**If page is blank or error:**
- Check Element logs
- Verify `ELEMENT_DEFAULT_HS` points to Synapse URL
- Check browser console (F12) for JavaScript errors

---

## Step 3: Full Registration Test

### 3.1 Register New User

1. Go to Element Web: `https://element-production-xxxx.up.railway.app`
2. Click **"Create Account"**
3. You should be redirected to: `https://mas-production-xxxx.up.railway.app/account/register`

**If redirect doesn't work:**
- Check MAS logs for errors
- Verify `MAS_CLIENT_REDIRECT_URI` includes Synapse URL + `/_synapse/client/oidc/callback`
- Check Synapse logs for OAuth errors

### 3.2 Complete Registration

Fill in form:
- **Username:** testuser1
- **Password:** SecurePass123!

Click **"Register"**

**Expected:**
- Registration succeeds
- Redirected back to Element
- Logged in automatically
- Shows "Welcome" message

**If registration fails:**
- Check MAS logs for detailed error
- Look for "password_registration_enabled: false" → should be true
- Check database connection to mas-db

### 3.3 Test Messaging

1. Click **"Create Room"**
2. Name: "Test Room"
3. Click **"Create"**
4. Type message: "Hello Matrix!"
5. Press Enter

**Expected:**
- Message appears in chat
- Timestamp shows

**If messaging fails:**
- Check Synapse logs
- Look for database write errors
- Check media_store permissions

---

## Step 4: Check Logs (Important!)

Before your presentation, review logs for any warnings:

### MAS Logs
```
Railway → mas service → Logs tab
```

**Look for:**
- ✅ "Listening on 0.0.0.0:8080"
- ✅ "Connected to database"
- ❌ "Failed to connect" → Fix database URI
- ❌ "Invalid signing key" → Fix MAS_SIGNING_KEY format

### Synapse Logs
```
Railway → synapse service → Logs tab
```

**Look for:**
- ✅ "Synapse now listening on TCP port 8008"
- ✅ "Database prepared"
- ❌ "Connection refused" → Check database variables
- ❌ "OAuth error" → Check MAS_* variables

### Element Logs
```
Railway → element-web service → Logs tab
```

**Look for:**
- ✅ "nginx started"
- ❌ "502 Bad Gateway" → Synapse not accessible

---

## Common Issues & Fixes

### Issue: MAS won't start - "Invalid key format"

**Cause:** MAS_SIGNING_KEY not in correct PEM format

**Fix:**
1. Go to MAS service → Variables
2. Check `MAS_SIGNING_KEY` value
3. Should start with: `-----BEGIN EC PRIVATE KEY-----`
4. Should end with: `-----END EC PRIVATE KEY-----`
5. Should have newlines preserved

**Correct format example:**
```
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIKj...base64...xyz
...more lines...
-----END EC PRIVATE KEY-----
```

---

### Issue: Synapse shows "Can't connect to MAS"

**Cause:** MAS_MATRIX_ENDPOINT points to wrong URL

**Fix:**
1. Go to MAS service → Settings → copy the Railway domain
2. Go to Synapse service → Variables
3. Update `MAS_MATRIX_ENDPOINT` to exact MAS URL
4. Update `MAS_CLIENT_REDIRECT_URI` to: `<synapse-url>/_synapse/client/oidc/callback`
5. Restart Synapse

---

### Issue: Registration redirects but fails

**Cause:** OAuth client redirect URI mismatch

**Fix:**
1. Check Synapse URL exactly: `https://synapse-production-abc123.up.railway.app`
2. Go to MAS Variables
3. Set `MAS_CLIENT_REDIRECT_URI` to: `<synapse-url>/_synapse/client/oidc/callback`
4. Restart MAS

---

### Issue: Database connection failed

**Cause:** Database not ready or wrong credentials

**Fix:**
1. Check database service is running (green)
2. Go to database → Connect
3. Copy the connection details
4. For Synapse: Use `${{synapse-db.PGUSER}}` etc. (Railway references)
5. For MAS: Use `${{mas-db.DATABASE_URL}}` (Railway reference)
6. Restart the service

---

### Issue: Element shows "Homeserver not reachable"

**Cause:** ELEMENT_DEFAULT_HS points to wrong URL

**Fix:**
1. Copy Synapse URL from Railway
2. Go to Element Variables
3. Set `ELEMENT_DEFAULT_HS` to exact Synapse URL (with https://)
4. Set `ELEMENT_DEFAULT_SERVER_NAME` to domain only (no https://)
5. Restart Element

---

## Quick Debug Commands

### Check if service is responding:

**Windows PowerShell:**
```powershell
# Test MAS
Invoke-WebRequest https://mas-production-xxxx.up.railway.app/.well-known/openid-configuration

# Test Synapse
Invoke-WebRequest https://synapse-production-xxxx.up.railway.app/_matrix/client/versions

# Test Element
Invoke-WebRequest https://element-production-xxxx.up.railway.app
```

---

## Emergency Pre-Presentation Checklist

**30 Minutes Before:**
- [ ] All 5 services green in Railway
- [ ] MAS health endpoint returns JSON
- [ ] Synapse health endpoint returns JSON
- [ ] Element homepage loads
- [ ] Test user registered successfully
- [ ] Test user can send messages

**15 Minutes Before:**
- [ ] Open Railway dashboard in one browser tab
- [ ] Open Element in another tab
- [ ] Create fresh test user for live demo
- [ ] Test sending message
- [ ] Clear browser cache/use incognito for clean demo

**5 Minutes Before:**
- [ ] All services still green
- [ ] Element still accessible
- [ ] Have Railway URLs ready to share
- [ ] Know your test credentials
- [ ] Have DEPLOY-NOW.md open as reference

---

## Presentation Demo Flow

### 1. Show Railway Dashboard (30 seconds)
"Here's our production deployment with 5 services running..."

### 2. Show Architecture (30 seconds)
"We have Synapse as the Matrix homeserver, MAS for authentication, Element as the client, and two PostgreSQL databases..."

### 3. Live Registration (2 minutes)
1. Open Element Web
2. Click "Create Account"
3. Shows MAS registration page
4. Fill in username/password
5. Register → redirected back to Element
6. Now logged in

### 4. Send Message (1 minute)
1. Create room
2. Type message
3. Send
4. Shows it works

### 5. Show Monitoring (1 minute)
1. Click Synapse service in Railway
2. Show logs scrolling
3. Show environment variables (redacted)
4. Show auto-generated domain

---

## Success Criteria

✅ **You're ready when:**
1. Can access all 3 public URLs
2. Registration flow completes end-to-end
3. Messages send successfully
4. All services have been running for at least 10 minutes
5. Logs show no critical errors
6. You can explain what each service does

---

## If Something Breaks During Presentation

**Stay calm!** Have these backup plans:

**Plan A: Restart the service**
- Click service → Settings → Restart

**Plan B: Show logs**
- "Let me show you the monitoring capabilities..."
- Show Railway logs feature
- Show how you debug

**Plan C: Use existing test user**
- Already logged in before presentation
- Show existing chat rooms
- Send messages from pre-existing account

**Plan D: Show architecture**
- Focus on design decisions
- Explain configuration choices
- Show Dockerfiles and configs
- Discuss scalability

---

## Post-Presentation Notes

After your presentation, consider:

1. **Add custom domains** (optional)
   - Railway → Service → Settings → Domains
   - Point your DNS records

2. **Enable monitoring** (optional)
   - Railway has built-in metrics
   - Check CPU, memory, network usage

3. **Scale up** (if needed)
   - Railway auto-scales based on demand
   - Can upgrade database size in settings

4. **Backup databases**
   - Railway databases have automatic backups
   - Check database settings for backup schedule

---

**You've got this! 🚀**

The deployment is solid, the configuration is correct, and you know how to debug issues. Trust your preparation!
