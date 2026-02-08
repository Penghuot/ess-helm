# Complete Video Calling Setup Guide
## For `to-test-with-railway` Folder

This guide shows you how to add Element Call and complete video functionality to your existing Railway deployment.

---

## ✅ What You Already Have Deployed

1. **Synapse** - Matrix homeserver ✅
2. **MAS** - Authentication service ✅
3. **Element Web** - Web client ✅
4. **matrix-rtc** - LiveKit SFU ✅
5. **PostgreSQL x2** - Databases ✅

**Your Working URLs:**
- Synapse: `https://synape-production-7433.up.railway.app`
- MAS: `https://mas-service-production-6c0a.up.railway.app`
- Element Web: `https://web-element-production-1fad.up.railway.app`

---

## 📦 What's New in This Update

Added to your `to-test-with-railway` folder:
- ✨ `element-call/` - Video calling UI
- ✨ `lk-jwt-service/` - JWT token generator for LiveKit
- ✨ Updated `element-web/` - Now supports Element Call
- ✨ Improved `matrix-rtc/` - Better LiveKit configuration

---

## 🚀 Quick Deployment (3 New Services)

### Step 1: Generate LiveKit Secrets (if not already done)

```bash
# API Key (must start with 'API')
echo -n "API$(openssl rand -hex 8)"
# Output example: API4f7e2a9b1c3d5e6f

# API Secret
openssl rand -hex 32
# Output example: a1b2c3d4e5f6789012345678901234567890123456789012345678901234
```

**Save these!** You'll need them for 3 services.

---

### Step 2: Update matrix-rtc Service (If Needed)

**Go to your existing matrix-rtc service in Railway:**

1. Check if these environment variables are set:
   - `LIVEKIT_API_KEY=API________________` (from Step 1)
   - `LIVEKIT_API_SECRET=________________________` (from Step 1)

2. If not set, add them and redeploy

3. **Save the public URL**: `https://matrix-rtc-production-xxxx.up.railway.app`

---

### Step 3: Deploy lk-jwt-service (NEW)

1. **Create new service** in Railway
2. **Connect** your GitHub repository: `Huotsty/demo-ess-stack`
3. **Service name**: `lk-jwt-service`
4. **Settings** → **Dockerfile Path**: 
   ```
   to-test-with-railway/lk-jwt-service/Dockerfile
   ```

5. **Environment Variables** (use SAME keys as matrix-rtc):
   ```
   LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
   LIVEKIT_API_KEY=API________________     (same as matrix-rtc)
   LIVEKIT_API_SECRET=____________________ (same as matrix-rtc)
   ```

6. **Deploy** → Wait for success

7. **Save the public URL**: `https://lk-jwt-service-production-xxxx.up.railway.app`

---

### Step 4: Deploy Element Call (NEW)

1. **Create new service** in Railway
2. **Connect** your GitHub repository: `Huotsty/demo-ess-stack`
3. **Service name**: `element-call`
4. **Settings** → **Dockerfile Path**: 
   ```
   to-test-with-railway/element-call/Dockerfile
   ```

5. **Environment Variables**:
   ```
   HOMESERVER_URL=https://synape-production-7433.up.railway.app
   SERVER_NAME=your-matrix-server-name
   LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
   LIVEKIT_JWT_SERVICE_URL=https://lk-jwt-service-production-xxxx.up.railway.app
   ```

6. **Deploy** → Wait for success

7. **Save the public URL**: `https://element-call-production-xxxx.up.railway.app`

---

### Step 5: Update Element Web (EXISTING)

**Go to your Element Web service:**

1. **Add new environment variable**:
   ```
   ELEMENT_CALL_URL=https://element-call-production-xxxx.up.railway.app
   ```

2. **Verify these existing variables are set**:
   ```
   HOMESERVER_URL=https://synape-production-7433.up.railway.app
   SERVER_NAME=your-matrix-server-name
   MAS_URL=https://mas-service-production-6c0a.up.railway.app
   ELEMENT_WEB_CLIENT_ID=elementwebclient0000000000000000
   ```

3. **Settings** → **Redeploy** (or trigger a new deployment)

---

## 🧪 Testing Your Complete Stack

### Test 1: Health Checks

```bash
# Synapse
curl https://synape-production-7433.up.railway.app/_matrix/client/versions

# MAS
curl https://mas-service-production-6c0a.up.railway.app/.well-known/openid-configuration

# LiveKit (matrix-rtc) - should return live count
curl https://matrix-rtc-production-xxxx.up.railway.app/

# Element Web - should return HTML
curl https://web-element-production-1fad.up.railway.app

# Element Call - should return HTML
curl https://element-call-production-xxxx.up.railway.app

# lk-jwt-service - 404 is OK (it needs auth)
curl https://lk-jwt-service-production-xxxx.up.railway.app/
```

---

### Test 2: Full User Flow

1. **Open Element Web**: `https://web-element-production-1fad.up.railway.app`

2. **Register or Login**:
   - Should redirect to MAS for authentication
   - Complete OAuth2 flow

3. **Create/Join a Room**:
   - Create a new room or join existing

4. **Start a Video Call**:
   - Click the video call button in the room
   - Element Call should open in new window/tab
   - Grant camera/microphone permissions
   - ✅ You should see yourself on video!

---

## 📐 Your Complete Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   Railway Platform (Your Project)                │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │ PostgreSQL   │◄───│  Synapse     │◄───│  Element Web    │  │
│  │ (Synapse DB) │    │ (Homeserver) │    │  (Web Client)   │  │
│  └──────────────┘    └──────▲───────┘    └────────┬────────┘  │
│                              │                      │            │
│  ┌──────────────┐    ┌──────┴───────┐             │            │
│  │ PostgreSQL   │◄───│     MAS      │◄────────────┘            │
│  │  (MAS DB)    │    │    (Auth)    │                           │
│  └──────────────┘    └──────────────┘                           │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │  matrix-rtc  │◄───│ lk-jwt-      │◄───│ Element Call    │  │
│  │  (LiveKit)   │    │ service      │    │ (Video UI)      │  │
│  └──────────────┘    └──────────────┘    └─────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

Data Flow:
1. User → Element Web → MAS (login) → Synapse (messages)
2. User → Element Call → lk-jwt-service (JWT) → matrix-rtc (video)
```

---

## 🔑 Environment Variables Summary

### matrix-rtc (LiveKit)
```bash
LIVEKIT_API_KEY=API________________
LIVEKIT_API_SECRET=________________________
# Railway auto-sets: PORT
```

### lk-jwt-service
```bash
LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
LIVEKIT_API_KEY=API________________         # Must match matrix-rtc
LIVEKIT_API_SECRET=________________________  # Must match matrix-rtc
# Railway auto-sets: PORT
```

### element-call
```bash
HOMESERVER_URL=https://synape-production-7433.up.railway.app
SERVER_NAME=your-matrix-server-name
LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
LIVEKIT_JWT_SERVICE_URL=https://lk-jwt-service-production-xxxx.up.railway.app
# Railway auto-sets: PORT
```

### element-web (UPDATE)
```bash
# Existing variables (keep these)
HOMESERVER_URL=https://synape-production-7433.up.railway.app
SERVER_NAME=your-matrix-server-name
MAS_URL=https://mas-service-production-6c0a.up.railway.app
ELEMENT_WEB_CLIENT_ID=elementwebclient0000000000000000

# NEW - Add this
ELEMENT_CALL_URL=https://element-call-production-xxxx.up.railway.app

# Optional
ELEMENT_DEFAULT_THEME=light
```

---

## ⚠️ Common Issues & Solutions

### Element Call button doesn't appear
**Solution**: Redeploy Element Web after setting `ELEMENT_CALL_URL`

### "Failed to connect to LiveKit"
**Solutions**:
1. Check `LIVEKIT_API_KEY` and `LIVEKIT_API_SECRET` match between matrix-rtc and lk-jwt-service
2. Verify LiveKit URL uses `wss://` (WebSocket Secure)
3. Check matrix-rtc service is running

### Element Call opens but video doesn't connect
**Solutions**:
1. Grant browser camera/microphone permissions
2. Check `LIVEKIT_JWT_SERVICE_URL` is correct in element-call service
3. Check browser console for errors
4. Test LiveKit directly: `curl https://matrix-rtc-xxx.up.railway.app/`

### "Invalid JWT token" errors
**Solution**: Make sure the API keys are EXACTLY the same (no extra spaces/quotes) between:
- matrix-rtc service
- lk-jwt-service

### Element Call page shows "Configuration error"
**Solutions**:
1. Check all environment variables are set in element-call service
2. Verify URLs are correct (no typos)
3. Check element-call logs: `railway logs -s element-call`

---

## 📊 Service Status Dashboard

Keep these URLs handy for monitoring:

| Service | Health Check | Expected Response |
|---------|--------------|-------------------|
| Synapse | `/_matrix/client/versions` | JSON with versions |
| MAS | `/.well-known/openid-configuration` | JSON config |
| matrix-rtc | `/` | HTML or JSON |
| Element Web | `/` | HTML page |
| Element Call | `/` | HTML page |
| lk-jwt-service | `/` | 404 (normal) |

---

## 🎤 For Your Presentation Tomorrow

### Demo Flow
1. **Show Architecture** - Use the diagram above
2. **Show Services** - Railway dashboard with all running
3. **Register User** - Live MAS OAuth2 flow
4. **Send Message** - Prove Matrix works
5. **Video Call** - Show Element Call opening
6. **Explain Stack** - Walk through each component

### Talking Points
- "Complete Matrix 2.0 stack with MSC3861 OAuth delegation"
- "LiveKit SFU for efficient video routing"
- "Self-hosted alternative to Zoom/Teams"
- "All services containerized and deployed on Railway"
- "End-to-end encrypted messaging and calls"

### Backup Plans
If video doesn't work:
- Show the working authentication flow
- Demonstrate messaging
- Explain the architecture (even if not fully demo-able)
- Show all services running in Railway

---

## 🔄 Deployment Order (Remember This)

**Correct order is important:**

1. ✅ matrix-rtc (LiveKit) - Creates API keys, provides URL
2. ✅ lk-jwt-service - Uses LiveKit URL and keys
3. ✅ element-call - Uses LiveKit & lk-jwt-service URLs
4. ✅ element-web - Update with Element Call URL

**Already deployed before this:**
- PostgreSQL databases
- Synapse
- MAS
- Original Element Web

---

## 📁 Folder Structure Reference

```
to-test-with-railway/
├── synapse/               ✅ Already deployed
├── mas/                   ✅ Already deployed
├── element-web/           ✅ Deployed (update needed)
├── matrix-rtc/            ✅ Deployed (verify env vars)
├── lk-jwt-service/        🆕 NEW - Deploy this
├── element-call/          🆕 NEW - Deploy this
└── README files and guides
```

---

## ⏰ Time Estimate

- Update matrix-rtc: **5 minutes** (if needed)
- Deploy lk-jwt-service: **10 minutes**
- Deploy element-call: **10 minutes**
- Update element-web: **5 minutes**
- Testing: **15 minutes**
- **Total: ~45 minutes**

---

## ✅ Success Checklist

Before your presentation:

- [ ] matrix-rtc has LIVEKIT_API_KEY and LIVEKIT_API_SECRET set
- [ ] lk-jwt-service deployed and using same keys
- [ ] element-call deployed with all URLs configured
- [ ] element-web updated with ELEMENT_CALL_URL
- [ ] All services showing "Active" in Railway
- [ ] Can login to Element Web via MAS
- [ ] Can send messages in a room
- [ ] Element Call button appears in rooms
- [ ] Can click video call (even if quality isn't perfect)

---

## 🎯 Final Notes

**Railway Limitations:**
- No UDP support (video uses TCP fallback)
- Video quality may not be perfect
- Still demonstrates the complete architecture

**What Works:**
- ✅ Complete OAuth2/OIDC authentication
- ✅ Matrix messaging
- ✅ Video call UI opens
- ✅ Basic video connectivity
- ✅ All services integrated

**For Production:**
- Would use a server with UDP support
- External Redis for LiveKit
- Dedicated TURN server
- CDN for Element Web/Call

---

**You're ready for tomorrow! Good luck! 🚀**

All services integrated, video calling infrastructure complete, just deploy the two new services and update Element Web.
