# Understanding matrix-rtc and Video Calling with Railway

## 🤔 Your Questions Answered

### Question 1: "How does matrix-rtc use the Matrix homeserver?"
**Answer:** matrix-rtc (LiveKit) does **NOT directly connect to Synapse**. Instead, clients connect to both separately.

### Question 2: "Railway is just one port per service?"
**Answer:** Railway automatically routes ONE public HTTP port (via `PORT` env var), but that's all you need. The video streams use WebSocket connections over that single port.

---

## 📊 How Video Calling Works (Without Direct Connection)

```
┌─────────────────────────────────────────────────────────────────┐
│                    VIDEO CALLING ARCHITECTURE                    │
└─────────────────────────────────────────────────────────────────┘

User's Browser (Element Web or Element Call)
    │
    ├─────────────── (1) Authenticate & Get Room Info ────────────┐
    │                                                              │
    ↓                                                              ↓
┌──────────────────────┐                              ┌──────────────────────┐
│    Synapse           │                              │        MAS           │
│  (Matrix Homeserver) │                              │ (Authentication)     │
│                      │                              │                      │
│  Port: 8008          │◄─────────────────────────────┤  Port: 8080          │
│  stores:             │   MSC3861 OAuth delegation   │  stores:             │
│  - rooms             │                              │  - users             │
│  - messages          │                              │  - passwords         │
│  - room members      │                              │  - OAuth tokens      │
└──────────────────────┘                              └──────────────────────┘
    │
    │ (2) User gets room info, sees video call invite
    │
    ↓
User clicks "Join Video Call"
    │
    ├─────────── (3) Request JWT Token for LiveKit ───────────────┐
    │                                                              │
    ↓                                                              ↓
┌──────────────────────┐                              ┌──────────────────────┐
│   lk-jwt-service     │                              │     matrix-rtc       │
│                      │                              │     (LiveKit SFU)    │
│  Port: 8080          │                              │                      │
│  Purpose:            │                              │  Port: 7880 (WSS)    │
│  - Generate JWT      │                              │  Purpose:            │
│  - Sign with         │                              │  - Video routing     │
│    LIVEKIT_API_KEY   │                              │  - Audio routing     │
│  - Validate user     │                              │  - WebRTC SFU        │
└──────────────────────┘                              └──────────────────────┘
    │                                                              ↑
    │ (4) Returns signed JWT token                                │
    │                                                              │
    ↓                                                              │
User's Browser receives JWT                                        │
    │                                                              │
    └─ (5) Connect to LiveKit via WebSocket ──────────────────────┘
           with JWT as authentication

All peers connect to LiveKit
    │
    └── LiveKit routes video/audio between peers (SFU mode)
```

---

## 🔍 Key Insight: NO Direct Connection Between Services

**matrix-rtc (LiveKit) does NOT talk to Synapse at all!**

Instead:
1. **Synapse** knows about the video call room
2. **User authentication** happens via Synapse/MAS (separate from video)
3. **lk-jwt-service** generates a token for the video connection
4. **matrix-rtc (LiveKit)** only handles video/audio streams

### Why This Design?

This is **decoupled architecture**:
- Matrix (Synapse) = messaging and room coordination
- LiveKit (matrix-rtc) = real-time video/audio streams
- JWT service = bridge between authentication systems

**Benefit:** If LiveKit crashes, Matrix messaging still works. If Synapse is slow, video isn't affected.

---

## 🚂 Railway's Port Limitation: NOT a Problem!

### Railway's Constraint:
- Each service gets **ONE public port** (set via `PORT` environment variable)
- Railway automatically provides HTTPS/WSS routing

### Why This Works:

#### Service 1: matrix-rtc (LiveKit)
```yaml
# livekit.production.yaml
port: 7880                    # ← Railway routes this to public URL
```

**What Railway does:**
- Exposes: `wss://matrix-rtc-prod-xxx.up.railway.app` (public WebSocket URL)
- Internally forwards to: `container:7880`
- **One port is enough because:**
  - All video/audio data goes over WebSocket connections
  - WebSocket multiplexes all streams over the same connection
  - No need for multiple ports!

#### Service 2: lk-jwt-service
```bash
# entrypoint.sh
export LK_JWT_PORT="${PORT:-8080}"
```

**What Railway does:**
- Exposes: `https://lk-jwt-service-prod-xxx.up.railway.app`
- Internally forwards to: `container:8080`
- Simple HTTP API for generating tokens

#### Service 3: element-call
```dockerfile
# Dockerfile runs nginx on port 80
```

**What Railway does:**
- Exposes: `https://element-call-prod-xxx.up.railway.app`
- Internally forwards to: `container:80`
- Static web app, just needs HTTP

---

## 🔧 What About Those Other Ports in livekit.production.yaml?

You might see this in the config:
```yaml
rtc:
  port_range_start: 50000
  port_range_end: 60000
  tcp_port: 7881
```

**These ports are NOT exposed to the internet!**

### Here's what they're for:

1. **port_range_start/end (50000-60000)**: UDP ports for peer-to-peer (P2P) mode
   - ❌ **NOT USED on Railway** (Railway doesn't support UDP)
   - We use TCP fallback instead

2. **tcp_port: 7881**: TCP fallback for RTC data
   - ✅ **Used internally** within the container
   - Railway doesn't need to expose this separately
   - All traffic goes through the main WebSocket port (7880)

### How WebSocket Multiplexing Works:

```
Client Browser ──wss://matrix-rtc-xxx.railway.app──> Railway Load Balancer
                                                           │
                                                           ↓
                                                    matrix-rtc container
                                                           │
                                                           ├─ Port 7880 (main WebSocket)
                                                           │    ├─ Stream 1: User A video
                                                           │    ├─ Stream 2: User A audio
                                                           │    ├─ Stream 3: User B video
                                                           │    ├─ Stream 4: User B audio
                                                           │    └─ Control messages
                                                           │
                                                           └─ Port 7881 (internal TCP)
                                                                Used for packet routing
                                                                Not exposed to internet
```

**One public port handles everything via multiplexing!**

---

## 🎯 Deployment Order & What Each Service Does

### Already Deployed (Core Services):

#### 1. **Synapse** - Matrix Homeserver
- **Port:** 8008
- **Purpose:** Store messages, rooms, users
- **Does NOT handle video**
- **Environment Required:**
  ```bash
  SYNAPSE_SERVER_NAME=synapse-prod-xxx.up.railway.app
  SYNAPSE_PUBLIC_BASEURL=https://synapse-prod-xxx.up.railway.app/
  MAS_PUBLIC_URL=https://mas-prod-xxx.up.railway.app
  # ... database settings ...
  ```

#### 2. **MAS** - Authentication Service
- **Port:** 8080
- **Purpose:** Login, register, OAuth tokens
- **Does NOT handle video**
- **Environment Required:**
  ```bash
  MAS_PUBLIC_BASE=https://mas-prod-xxx.up.railway.app
  MAS_MATRIX_HOMESERVER=http://synapse.railway.internal:8008
  MAS_MATRIX_ENDPOINT=https://synapse-prod-xxx.up.railway.app
  # ... secrets ...
  ```

#### 3. **Element Web** - Web Client
- **Port:** 80 (nginx)
- **Purpose:** User interface
- **Does NOT handle video** (redirects to Element Call)
- **Environment Required:**
  ```bash
  HOMESERVER_URL=https://synapse-prod-xxx.up.railway.app
  MAS_URL=https://mas-prod-xxx.up.railway.app
  ELEMENT_WEB_CLIENT_ID=element-web-xxx
  ```

---

### Need to Deploy (Video Services):

#### 4. **matrix-rtc** - LiveKit SFU (Deploy FIRST)
- **Port:** 7880 (WebSocket)
- **Purpose:** Route video/audio between users
- **Does NOT talk to Synapse** - just handles media streams
- **Environment Required:**
  ```bash
  LIVEKIT_API_KEY=your-random-key-here      # Generate this yourself!
  LIVEKIT_API_SECRET=your-random-secret-here # Generate this yourself!
  ```
  
**Generate API key/secret:**
```bash
# On your local machine:
LIVEKIT_API_KEY=$(openssl rand -hex 16)
LIVEKIT_API_SECRET=$(openssl rand -hex 32)
echo "LIVEKIT_API_KEY=$LIVEKIT_API_KEY"
echo "LIVEKIT_API_SECRET=$LIVEKIT_API_SECRET"
```

**After deployment, get the public URL:**
```bash
# Railway will give you:
wss://matrix-rtc-prod-xxxx.up.railway.app
```

#### 5. **lk-jwt-service** - JWT Token Generator (Deploy SECOND)
- **Port:** 8080
- **Purpose:** Generate JWT tokens for LiveKit authentication
- **Does NOT talk to Synapse** - just signs tokens
- **Environment Required:**
  ```bash
  LIVEKIT_URL=wss://matrix-rtc-prod-xxxx.up.railway.app  # From step 4
  LIVEKIT_API_KEY=<same as matrix-rtc>                   # MUST MATCH!
  LIVEKIT_API_SECRET=<same as matrix-rtc>                # MUST MATCH!
  ```

**After deployment, get the public URL:**
```bash
# Railway will give you:
https://lk-jwt-service-prod-xxxx.up.railway.app
```

#### 6. **element-call** - Video Call UI (Deploy THIRD)
- **Port:** 80 (nginx)
- **Purpose:** Video calling interface
- **Talks to:** Synapse (for auth), lk-jwt-service (for tokens), matrix-rtc (for video)
- **Environment Required:**
  ```bash
  HOMESERVER_URL=https://synapse-prod-xxx.up.railway.app   # From step 1
  SERVER_NAME=synapse-prod-xxx.up.railway.app              # Same as step 1
  LIVEKIT_URL=wss://matrix-rtc-prod-xxxx.up.railway.app    # From step 4
  LIVEKIT_JWT_SERVICE_URL=https://lk-jwt-service-prod-xxxx.up.railway.app  # From step 5
  ```

**After deployment, get the public URL:**
```bash
# Railway will give you:
https://element-call-prod-xxxx.up.railway.app
```

#### 7. **element-web** - Update Existing (Deploy LAST)
- Just add new environment variable:
  ```bash
  ELEMENT_CALL_URL=https://element-call-prod-xxxx.up.railway.app  # From step 6
  ```
- Redeploy Element Web

---

## 🔄 Complete Video Call Flow

### Step-by-Step:

```
1. User logs in to Element Web
   └─> Auth via MAS/Synapse (already working)

2. User clicks "Start Video Call" in a room
   └─> Element Web redirects to: https://element-call-prod-xxxx.up.railway.app/?room=...

3. Element Call loads in browser
   └─> Reads config.json:
       {
         "livekit_service_url": "wss://matrix-rtc-prod-xxxx.up.railway.app",
         "livekit_jwt_service_url": "https://lk-jwt-service-prod-xxxx.up.railway.app"
       }

4. Element Call requests JWT token
   └─> POST https://lk-jwt-service-prod-xxxx.up.railway.app/token
       Body: { room: "!abc123:synapse.app", user: "@user:synapse.app" }

5. lk-jwt-service generates signed JWT
   └─> Uses LIVEKIT_API_KEY and LIVEKIT_API_SECRET to sign
   └─> Returns: { token: "eyJhbGciOiJIUzI1NiIs..." }

6. Element Call connects to LiveKit
   └─> WebSocket: wss://matrix-rtc-prod-xxxx.up.railway.app
       Header: Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

7. matrix-rtc validates JWT
   └─> Verifies signature using LIVEKIT_API_KEY
   └─> Allows connection if valid

8. Video stream established
   └─> All video/audio data flows through matrix-rtc (LiveKit SFU)
   └─> Other users in same room connect the same way
```

---

## ✅ Why Railway's Port Limitation Doesn't Matter

### Traditional Video Servers (Bad for Railway):
```
Video Server needs:
- Port 1000: Signaling
- Port 1001-2000: RTP (video streams)
- Port 3000-4000: RTCP (control)
- Port 5000-6000: UDP streams

❌ Requires 3000+ ports exposed!
❌ Doesn't work on Railway
```

### LiveKit with WebSocket (Perfect for Railway):
```
LiveKit needs:
- Port 7880: WebSocket (handles EVERYTHING)
  ├─ Signaling
  ├─ Video streams (multiplexed)
  ├─ Audio streams (multiplexed)
  ├─ Control messages
  └─ All data over single connection

✅ Only 1 port exposed!
✅ Works perfectly on Railway!
```

---

## 🎯 Quick Deployment Checklist

### What You Need to Do:

#### Step 1: Deploy matrix-rtc
```bash
# Railway dashboard:
Service: matrix-rtc
Dockerfile path: to-test-with-railway/matrix-rtc/Dockerfile

Environment Variables:
LIVEKIT_API_KEY = <generate random 32 chars>
LIVEKIT_API_SECRET = <generate random 64 chars>

# Save the public URL after deployment:
# wss://matrix-rtc-prod-xxxx.up.railway.app
```

#### Step 2: Deploy lk-jwt-service
```bash
# Railway dashboard:
Service: lk-jwt-service
Dockerfile path: to-test-with-railway/lk-jwt-service/Dockerfile

Environment Variables:
LIVEKIT_URL = wss://matrix-rtc-prod-xxxx.up.railway.app  # From step 1
LIVEKIT_API_KEY = <same as step 1>
LIVEKIT_API_SECRET = <same as step 1>

# Save the public URL after deployment:
# https://lk-jwt-service-prod-xxxx.up.railway.app
```

#### Step 3: Deploy element-call
```bash
# Railway dashboard:
Service: element-call
Dockerfile path: to-test-with-railway/element-call/Dockerfile

Environment Variables:
HOMESERVER_URL = https://synapse-prod-xxx.up.railway.app
SERVER_NAME = synapse-prod-xxx.up.railway.app
LIVEKIT_URL = wss://matrix-rtc-prod-xxxx.up.railway.app  # From step 1
LIVEKIT_JWT_SERVICE_URL = https://lk-jwt-service-prod-xxxx.up.railway.app  # From step 2

# Save the public URL after deployment:
# https://element-call-prod-xxxx.up.railway.app
```

#### Step 4: Update element-web
```bash
# Railway dashboard:
Service: element-web (existing)

Add Environment Variable:
ELEMENT_CALL_URL = https://element-call-prod-xxxx.up.railway.app  # From step 3

# Redeploy
```

---

## 🧪 Testing

### Test 1: matrix-rtc is running
```bash
# Should show LiveKit server info:
curl https://matrix-rtc-prod-xxxx.up.railway.app
```

### Test 2: lk-jwt-service is running
```bash
# Should return error (needs proper auth params):
curl https://lk-jwt-service-prod-xxxx.up.railway.app/token
```

### Test 3: element-call loads
```bash
# Should show Element Call interface:
Open: https://element-call-prod-xxxx.up.railway.app
```

### Test 4: Full flow
1. Login to Element Web
2. Create or join a room
3. Look for "Start video call" button
4. Click it → should redirect to Element Call
5. Should ask for camera permission
6. Video should connect!

---

## 📝 Summary

**matrix-rtc does NOT connect to Synapse!**

Instead:
- matrix-rtc = standalone video routing server (SFU)
- Authentication happens separately via MAS/Synapse
- lk-jwt-service bridges the authentication
- Element Call connects to both systems

**Railway's one-port-per-service is PERFECT for this!**

All video traffic goes over WebSocket multiplexing, so you only need:
- 1 port for matrix-rtc (7880 → Railway exposes as public WSS)
- 1 port for lk-jwt-service (8080 → Railway exposes as public HTTPS)
- 1 port for element-call (80 → Railway exposes as public HTTPS)

**You're ready to deploy!** 🚀

