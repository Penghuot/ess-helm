FROM matrixdotorg/synapse:latest

# Switch to root to set up directories and permissions
USER root

# Copy the generated synapse config
COPY synapse-config /data

# Copy your custom homeserver.yaml to override defaults
COPY homeserver.yaml /data/homeserver.yaml

# Create necessary directories with proper permissions
RUN mkdir -p /data/media_store && \
    chown -R 991:991 /data && \
    chmod -R 755 /data

# Switch back to synapse user
USER 991

# Expose port 8008
EXPOSE 8008

# Run synapse
CMD ["run"]

