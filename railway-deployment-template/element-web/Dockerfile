# ============================================================================
# Element Web Dockerfile - Railway Template
# ============================================================================
# This Dockerfile builds Element Web with runtime configuration injection
# using environment variables.
#
# Environment Variables Required:
# - ELEMENT_HOMESERVER_URL (Synapse public URL)
# - ELEMENT_HOMESERVER_NAME (Matrix server name)
# ============================================================================

FROM vectorim/element-web:latest

# Install envsubst for environment variable substitution
USER root
RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration template and entrypoint
COPY element-web/config.json.template /app/config.json.template
COPY element-web/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to nginx user
USER nginx

# Expose HTTP port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Use custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]
