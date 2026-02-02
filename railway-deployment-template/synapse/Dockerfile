# ============================================================================
# Synapse Dockerfile - Railway Template
# ============================================================================
# This Dockerfile builds a production-ready Synapse homeserver that uses
# environment variables for all configuration, avoiding hardcoded secrets.
#
# Environment Variables Required:
# - PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE (Database)
# - SYNAPSE_SERVER_NAME (Your Matrix domain)
# - SYNAPSE_PUBLIC_BASEURL (Public URL)
# - SYNAPSE_REGISTRATION_SHARED_SECRET (For admin tools)
# - SYNAPSE_MACAROON_SECRET_KEY (Session tokens)
# - SYNAPSE_FORM_SECRET (CSRF protection)
# - SYNAPSE_SIGNING_KEY (Federation signing)
# ============================================================================

FROM matrixdotorg/synapse:latest

# Install envsubst for environment variable substitution
USER root
RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories with proper permissions
RUN mkdir -p /data/media_store /data/uploads /config && \
    chown -R 991:991 /data /config

# Copy configuration template and entrypoint script
COPY --chown=991:991 homeserver.yaml.template /config/homeserver.yaml.template
COPY --chown=991:991 log.config.yaml /config/log.config.yaml
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Switch back to non-root user for security
USER 991

# Expose Synapse port
EXPOSE 8008

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8008/_matrix/static/ || exit 1

# Use custom entrypoint that generates config from template
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
