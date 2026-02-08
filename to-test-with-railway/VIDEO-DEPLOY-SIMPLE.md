# Quick Reference: Deploying Video Services

## 🎯 Simple Answer to Your Questions

### Q: "Does matrix-rtc talk to Synapse?"
**A: NO!** matrix-rtc is completely separate. It only handles video/audio streams.

### Q: "Railway only has one port per service?"
**A: YES, and that's perfect!** All video data goes through WebSocket on that one port.

---

## 📦 What to Deploy (In Order)

### ✅ Already Working
1. **Synapse** - Stores messages
2. **MAS** - Handles login
3. **Element Web** - User interface

### 🎥 Need to Deploy for Video
4. **matrix-rtc** (LiveKit) - Routes video/audio
5. **lk-jwt-service** - Generates video auth tokens
6. **element-call** - Video calling UI

---

## 🚀 Deployment Steps (Copy & Paste)

### Step 1: Deploy matrix-rtc

**Railway Settings:**
- Service name: `matrix-rtc`
- Dockerfile: `to-test-with-railway/matrix-rtc/Dockerfile`

**Environment Variables:**
```bash
LIVEKIT_API_KEY=dev-api-key-123456789abcdef
LIVEKIT_API_SECRET=dev-secret-abcdef123456789abcdef123456789ab
```
> Generate random values! Save these for next step!

**After Deploy:**
- Copy the public URL: `wss://matrix-rtc-production-xxxx.up.railway.app`

---

### Step 2: Deploy lk-jwt-service

**Railway Settings:**
- Service name: `lk-jwt-service`
- Dockerfile: `to-test-with-railway/lk-jwt-service/Dockerfile`

**Environment Variables:**
```bash
LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
LIVEKIT_API_KEY=dev-api-key-123456789abcdef          # SAME as Step 1
LIVEKIT_API_SECRET=dev-secret-abcdef123456789abcdef  # SAME as Step 1
```

**After Deploy:**
- Copy the public URL: `https://lk-jwt-service-production-xxxx.up.railway.app`

---

### Step 3: Deploy element-call

**Railway Settings:**
- Service name: `element-call`
- Dockerfile: `to-test-with-railway/element-call/Dockerfile`

**Environment Variables:**
```bash
HOMESERVER_URL=https://synapse-production-xxx.up.railway.app
SERVER_NAME=synapse-production-xxx.up.railway.app
LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app        # From Step 1
LIVEKIT_JWT_SERVICE_URL=https://lk-jwt-service-production-xxxx.up.railway.app  # From Step 2
```

**After Deploy:**
- Copy the public URL: `https://element-call-production-xxxx.up.railway.app`

---

### Step 4: Update Element Web

**Railway Settings:**
- Service name: `element-web` (existing service)
- Just add ONE new environment variable

**Add Environment Variable:**
```bash
ELEMENT_CALL_URL=https://element-call-production-xxxx.up.railway.app  # From Step 3
```

**Then:** Click "Redeploy"

---

## ✅ Testing

### Test 1: Services Running
Check Railway dashboard - all should be green:
- ✅ matrix-rtc
- ✅ lk-jwt-service
- ✅ element-call
- ✅ element-web (redeployed)

### Test 2: Login
1. Go to your Element Web URL
2. Login with username/password
3. Should work (already working before)

### Test 3: Video Call
1. Create a room or join existing room
2. Look for "Start video call" button
3. Click it
4. Should redirect to Element Call
5. Browser asks for camera permission
6. Accept → video should work!

---

## 🔑 Key Points

1. **matrix-rtc doesn't connect to Synapse**
   - It's a separate video server
   - Authentication happens via JWT tokens

2. **One port per service is enough**
   - WebSocket multiplexes all streams
   - Railway handles this automatically

3. **API key/secret must match**
   - matrix-rtc: uses key to validate tokens
   - lk-jwt-service: uses same key to sign tokens
   - If they don't match → video won't work

4. **Deploy order matters**
   - matrix-rtc FIRST (generates URLs)
   - lk-jwt-service SECOND (needs matrix-rtc URL)
   - element-call THIRD (needs both URLs)
   - element-web LAST (needs element-call URL)

---

## 🆘 If Video Doesn't Work

### Check 1: API Keys Match
```bash
# On Railway dashboard:
matrix-rtc service:
  LIVEKIT_API_KEY = abc123
  LIVEKIT_API_SECRET = xyz789

lk-jwt-service service:
  LIVEKIT_API_KEY = abc123     ← Must be IDENTICAL
  LIVEKIT_API_SECRET = xyz789  ← Must be IDENTICAL
```

### Check 2: URLs Are Correct
```bash
# element-call service:
LIVEKIT_URL = wss://matrix-rtc-xxx...  ← Must start with wss://
LIVEKIT_JWT_SERVICE_URL = https://lk-jwt-service-xxx...  ← Must start with https://
```

### Check 3: Element Web Has URL
```bash
# element-web service:
ELEMENT_CALL_URL = https://element-call-xxx...  ← Must be set!
```

---

## 📊 Architecture Diagram

See the diagram above! Green = already deployed, Pink = need to deploy

**Flow:**
1. User logs in (MAS + Synapse)
2. User clicks video call
3. Element Call requests JWT from lk-jwt-service
4. Element Call connects to matrix-rtc with JWT
5. Video streams!

---

## ⏱️ Time Estimate

- Deploy matrix-rtc: 5 minutes
- Deploy lk-jwt-service: 5 minutes
- Deploy element-call: 5 minutes
- Update element-web: 2 minutes
- **Total: ~20 minutes**

**You got this! 🚀**
