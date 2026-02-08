# Element Call

Element Call is the video calling UI for Matrix 2.0.

## Environment Variables

**Required:**
- `HOMESERVER_URL` - Your Synapse homeserver (e.g., `https://synape-production-7433.up.railway.app`)
- `SERVER_NAME` - Your Matrix server name
- `LIVEKIT_URL` - LiveKit WebSocket URL (from matrix-rtc service, e.g., `wss://matrix-rtc-production-xxxx.up.railway.app`)
- `LIVEKIT_JWT_SERVICE_URL` - JWT service URL (e.g., `https://lk-jwt-service-production-xxxx.up.railway.app`)

**Optional:**
- `PORT` - Railway sets this automatically

## Railway Deployment

1. Create new service in Railway
2. Connect your GitHub repository
3. Set Dockerfile path: `to-test-with-railway/element-call/Dockerfile`
4. Set environment variables (see above)
5. Deploy

## Integration

Element Web needs to know about Element Call. Add this to Element Web config:
```json
{
  "element_call": {
    "url": "https://element-call-production-xxxx.up.railway.app",
    "participant_limit": 20
  }
}
```
