# Quick Start - Add Video Calling NOW

For your presentation tomorrow - this is the TL;DR version.

## What to Do (3 Steps)

### 1. Deploy lk-jwt-service

**Railway Dashboard:**
- New Service → GitHub repo: `Huotsty/demo-ess-stack`  
- Dockerfile path: `to-test-with-railway/lk-jwt-service/Dockerfile`

**Environment Variables:**
```bash
LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app  # Your matrix-rtc URL
LIVEKIT_API_KEY=API________________                          # Check matrix-rtc service
LIVEKIT_API_SECRET=____________________                      # Check matrix-rtc service
```

**Note:** API_KEY and SECRET must match your matrix-rtc service exactly!

---

### 2. Deploy element-call

**Railway Dashboard:**
- New Service → GitHub repo: `Huotsty/demo-ess-stack`
- Dockerfile path: `to-test-with-railway/element-call/Dockerfile`

**Environment Variables:**
```bash
HOMESERVER_URL=https://synape-production-7433.up.railway.app
SERVER_NAME=your-server-name
LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
LIVEKIT_JWT_SERVICE_URL=https://lk-jwt-service-production-xxxx.up.railway.app  # From step 1
```

---

### 3. Update element-web

**Go to your existing Element Web service:**

**Add ONE new variable:**
```bash
ELEMENT_CALL_URL=https://element-call-production-xxxx.up.railway.app  # From step 2
```

**Then: Redeploy**

---

## Test It

1. Open: `https://web-element-production-1fad.up.railway.app`
2. Login (via MAS)
3. Go to any room
4. Look for video call button
5. Click it → Element Call should open
6. ✅ Done!

---

## If Something Breaks

### Element Call button missing?
→ Check `ELEMENT_CALL_URL` is set in Element Web → Redeploy

### Video won't connect?
→ Check API keys match between matrix-rtc and lk-jwt-service

### "Configuration error"?
→ Check all URLs in element-call are correct

---

## What You're Deploying

```
Your Existing Stack:
✅ Synapse
✅ MAS  
✅ Element Web
✅ matrix-rtc (LiveKit)

Adding Today:
🆕 lk-jwt-service (JWT tokens)
🆕 element-call (Video UI)
🔄 Element Web update (add Element Call URL)
```

---

**Time needed: 30-45 minutes**

**Result: Complete Matrix 2.0 stack with video calling!**

Deploy now, test tonight, present confidently tomorrow! 💪
