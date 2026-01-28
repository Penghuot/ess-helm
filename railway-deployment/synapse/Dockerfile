FROM matrixdotorg/synapse:v1.118.0

# Install PostgreSQL client for database operations
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to synapse user
USER 991

# Copy custom homeserver configuration
COPY --chown=991:991 homeserver.yaml /data/homeserver.yaml
COPY --chown=991:991 log.config.yaml /data/log.config.yaml

# Create media store directory
RUN mkdir -p /data/media_store && \
    chown -R 991:991 /data/media_store

# Expose Synapse port
EXPOSE 8008

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8008/health || exit 1

# Start Synapse
CMD ["python", "-m", "synapse.app.homeserver", "-c", "/data/homeserver.yaml"]