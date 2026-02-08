# Element Call Dockerfile for Railway
# Using official Element HQ image from GitHub Container Registry
FROM ghcr.io/element-hq/element-call:latest

# Copy configuration files
COPY config.template.json /app/config.template.json
COPY --chmod=755 entrypoint.sh /entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
