# LiveKit JWT Service Dockerfile
# Using official Element HQ image from GitHub Container Registry
# Image: ghcr.io/element-hq/lk-jwt-service (minimal distroless image)
# Latest published: 24 hours ago (active maintenance)
#
# NOTE: This is a distroless image with no shell (/bin/sh)
# Environment variables are set by Railway and passed to the binary
# Required env vars: LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET
FROM ghcr.io/element-hq/lk-jwt-service:latest

# Expose the default port
EXPOSE 8080

# The image already has the binary as entrypoint
# Railway will set PORT environment variable automatically
# Just run the service (no shell needed)
