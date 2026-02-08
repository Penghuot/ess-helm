# LiveKit Server (SFU for video/audio routing)
# Using official LiveKit image from Docker Hub
# Image: livekit/livekit-server
# Latest published: 2 days ago (active maintenance)
FROM livekit/livekit-server:latest

# Copy the production config
COPY livekit.production.yaml /etc/livekit.yaml

EXPOSE 7880

# Start LiveKit with environment variable substitution
CMD ["livekit-server", "--config", "/etc/livekit.yaml"]
