# ============================================================================
# Synapse Dockerfile - Railway Template
# ============================================================================
# Environment variables set in Railway:
# - SYNAPSE_SERVER_NAME, SYNAPSE_PUBLIC_BASEURL
# - DATABASE_URL (Railway provides this for PostgreSQL)
# - SYNAPSE_REGISTRATION_SHARED_SECRET, SYNAPSE_MACAROON_SECRET_KEY
# - SYNAPSE_FORM_SECRET, SYNAPSE_SIGNING_KEY
# ============================================================================

FROM matrixdotorg/synapse:latest

USER root

# Create media store directory
RUN mkdir -p /data/media_store && chown -R 991:991 /data

# Copy configs
COPY homeserver.yaml.template /homeserver.yaml.template
COPY log.config.yaml /data/log.config.yaml
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh && \
    chown 991:991 /data/log.config.yaml

USER 991

EXPOSE 8008

# Use custom entrypoint to substitute env vars
ENTRYPOINT ["/entrypoint.sh"]
