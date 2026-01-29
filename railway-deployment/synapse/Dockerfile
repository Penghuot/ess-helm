FROM matrixdotorg/synapse:latest

# Switch to root to set up directories and permissions
USER root

# Copy config files into the image (will be synced to /data at startup)
COPY synapse-config /config
COPY homeserver.yaml /config/homeserver.yaml

# Startup script to sync config into /data (handles persistent volumes)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create necessary directories with proper permissions
RUN mkdir -p /data/media_store && \
    chown -R 991:991 /data && \
    chmod -R 755 /data

# Switch back to synapse user
USER 991

# Expose port 8008
EXPOSE 8008

# Use custom entrypoint to ensure config is synced into /data
ENTRYPOINT ["/entrypoint.sh"]
