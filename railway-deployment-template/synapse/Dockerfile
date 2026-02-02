FROM matrixdotorg/synapse:latest

USER root

# Install envsubst for environment variable substitution
RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Create media store directory
RUN mkdir -p /data/media_store && chown -R 991:991 /data

# Copy configs
COPY synapse/homeserver.yaml.template /homeserver.yaml.template
COPY synapse/log.config.yaml /data/log.config.yaml
COPY synapse/entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh && \
    chown 991:991 /data/log.config.yaml

USER 991

EXPOSE 8008

ENTRYPOINT ["/entrypoint.sh"]
