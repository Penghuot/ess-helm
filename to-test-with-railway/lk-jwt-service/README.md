# LiveKit JWT Service

This service generates JWT tokens for LiveKit access.

## Environment Variables

**Required:**
- `LIVEKIT_URL` - LiveKit WebSocket URL (from matrix-rtc, e.g., `wss://matrix-rtc-production-xxxx.up.railway.app`)
- `LIVEKIT_API_KEY` - LiveKit API key (must match matrix-rtc service)
- `LIVEKIT_API_SECRET` - LiveKit secret (must match matrix-rtc service)

**Optional:**
- `PORT` - Railway sets this automatically (default: 8080)

## Railway Deployment

1. Create new service in Railway
2. Connect your GitHub repository
3. Set Dockerfile path: `to-test-with-railway/lk-jwt-service/Dockerfile`
4. Set environment variables:
   ```
   LIVEKIT_URL=wss://matrix-rtc-production-xxxx.up.railway.app
   LIVEKIT_API_KEY=<same as matrix-rtc>
   LIVEKIT_API_SECRET=<same as matrix-rtc>
   ```
5. Deploy

## Important

The `LIVEKIT_API_KEY` and `LIVEKIT_API_SECRET` **MUST** be the same values as your matrix-rtc (LiveKit) service.
