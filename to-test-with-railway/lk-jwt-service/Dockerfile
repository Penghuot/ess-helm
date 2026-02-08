# LiveKit JWT Service Dockerfile
# Using official Element HQ image from GitHub Container Registry
# Image: ghcr.io/element-hq/lk-jwt-service
# Latest published: 24 hours ago (active maintenance)
FROM ghcr.io/element-hq/lk-jwt-service:latest

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the default port
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
