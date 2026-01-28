FROM matrixdotorg/synapse:v1.118.0

# Copy configs (make sure they exist in repo root)
COPY homeserver.yaml /data/homeserver.yaml
COPY log.config.yaml /data/log.config.yaml

# Create media store directory
RUN mkdir -p /data/media_store && \
    chown -R 991:991 /data/media_store

# Expose Synapse port
EXPOSE 8008

# Start Synapse (use built-in entrypoint)
CMD ["python", "-m", "synapse.app.homeserver", "-c", "/data/homeserver.yaml"]
