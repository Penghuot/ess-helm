# Use latest stable Synapse version
FROM matrixdotorg/synapse:v1.120.1

USER root

# Install required utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    curl \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY --chown=991:991 homeserver.yaml /data/homeserver.yaml
COPY --chown=991:991 log.config.yaml /data/log.config.yaml
COPY --chown=991:991 start.sh /start.sh
RUN chmod +x /start.sh

# Create necessary directories
RUN mkdir -p /data/media_store /data/keys && \
    chown -R 991:991 /data

# Switch to synapse user
USER 991

EXPOSE 8008

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD curl -f http://localhost:8008/health || exit 1

ENTRYPOINT ["/start.sh"]
