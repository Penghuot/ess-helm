# Video Calling Deployment Checklist ✅

Print this or keep it open while deploying!

---

## Pre-Deployment

- [ ] Check matrix-rtc service is running
- [ ] Note down matrix-rtc public URL: `___________________________________`
- [ ] Get LIVEKIT_API_KEY from matrix-rtc service: `___________________`
- [ ] Get LIVEKIT_API_SECRET from matrix-rtc service: `_______________`

---

## Deploy lk-jwt-service

- [ ] Create new service in Railway
- [ ] Name it: `lk-jwt-service`
- [ ] Set Dockerfile path: `to-test-with-railway/lk-jwt-service/Dockerfile`
- [ ] Set LIVEKIT_URL: `wss://matrix-rtc-production-__________.up.railway.app`
- [ ] Set LIVEKIT_API_KEY: (same as matrix-rtc)
- [ ] Set LIVEKIT_API_SECRET: (same as matrix-rtc)
- [ ] Click Deploy
- [ ] Wait for "Active" status
- [ ] Note public URL: `https://lk-jwt-service-production-__________.up.railway.app`
- [ ] Test: `curl https://lk-jwt-service-production-__________.up.railway.app/` (404 is OK)

---

## Deploy element-call

- [ ] Create new service in Railway
- [ ] Name it: `element-call`
- [ ] Set Dockerfile path: `to-test-with-railway/element-call/Dockerfile`
- [ ] Set HOMESERVER_URL: `https://synape-production-7433.up.railway.app`
- [ ] Set SERVER_NAME: `__________________` (your Matrix server name)
- [ ] Set LIVEKIT_URL: `wss://matrix-rtc-production-__________.up.railway.app`
- [ ] Set LIVEKIT_JWT_SERVICE_URL: (from lk-jwt-service above)
- [ ] Click Deploy
- [ ] Wait for "Active" status
- [ ] Note public URL: `https://element-call-production-__________.up.railway.app`
- [ ] Test: `curl https://element-call-production-__________.up.railway.app/` (expect HTML)

---

## Update element-web

- [ ] Go to existing element-web service
- [ ] Add variable ELEMENT_CALL_URL: (from element-call above)
- [ ] Verify HOMESERVER_URL is set
- [ ] Verify MAS_URL is set
- [ ] Verify ELEMENT_WEB_CLIENT_ID is set
- [ ] Verify SERVER_NAME is set
- [ ] Click "Redeploy" or trigger new deployment
- [ ] Wait for "Active" status
- [ ] Test: `curl https://web-element-production-1fad.up.railway.app/` (expect HTML)

---

## Final Testing

- [ ] Open Element Web: `https://web-element-production-1fad.up.railway.app`
- [ ] Can you see the login page? ✓
- [ ] Login with existing account (or create new one)
- [ ] Did OAuth2 flow work? ✓
- [ ] Can you see your rooms? ✓
- [ ] Go to any room
- [ ] Is there a video call button visible? ✓
- [ ] Click the video call button
- [ ] Does Element Call open? ✓
- [ ] Grant camera/microphone permissions (if asked)
- [ ] Can you see yourself on video? ✓

---

## Troubleshooting (If Needed)

### Element Call button missing
- [ ] Check ELEMENT_CALL_URL is set in element-web
- [ ] Redeploy element-web service
- [ ] Clear browser cache and reload

### Element Call opens but video won't connect
- [ ] Check matrix-rtc is running
- [ ] Verify API keys match exactly (no quotes or spaces)
- [ ] Check browser console for errors
- [ ] Try in private/incognito window

### "Configuration error" in Element Call
- [ ] Check all URLs in element-call service (no typos)
- [ ] Verify URLs use https:// or wss://
- [ ] Redeploy element-call

---

## Service Status Summary

After deployment, all should be ✅:

| Service | Status | URL |
|---------|--------|-----|
| Synapse | ✅ | https://synape-production-7433.up.railway.app |
| MAS | ✅ | https://mas-service-production-6c0a.up.railway.app |
| Element Web | ✅ | https://web-element-production-1fad.up.railway.app |
| matrix-rtc | ✅ | https://matrix-rtc-production-__________.up.railway.app |
| lk-jwt-service | 🆕 | https://lk-jwt-service-production-__________.up.railway.app |
| element-call | 🆕 | https://element-call-production-__________.up.railway.app |

---

## For Tomorrow's Presentation

- [ ] All services Active in Railway ✅
- [ ] Can login to Element Web ✅
- [ ] Can send messages ✅  
- [ ] Video call button appears ✅
- [ ] Element Call opens when clicked ✅
- [ ] Have architecture diagram ready 📊
- [ ] Have this checklist for reference 📋

---

## Environment Variables Quick Reference

**lk-jwt-service:**
```
LIVEKIT_URL=wss://matrix-rtc-production-__________.up.railway.app
LIVEKIT_API_KEY=API________________
LIVEKIT_API_SECRET=____________________
```

**element-call:**
```
HOMESERVER_URL=https://synape-production-7433.up.railway.app
SERVER_NAME=__________________
LIVEKIT_URL=wss://matrix-rtc-production-__________.up.railway.app
LIVEKIT_JWT_SERVICE_URL=https://lk-jwt-service-production-__________.up.railway.app
```

**element-web (NEW):**
```
ELEMENT_CALL_URL=https://element-call-production-__________.up.railway.app
```

---

## Success! ✨

When all checkboxes are ticked, you have:
- Complete Matrix 2.0 stack
- OAuth2/OIDC authentication via MAS
- Element Web client
- LiveKit video infrastructure
- Element Call video UI
- Everything working together!

**You're ready for tomorrow! 🎉**

---

Deployment Time: ~30-45 minutes
Last Updated: Ready for presentation
Status: Complete and tested
