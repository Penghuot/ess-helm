# ============================================================================
# MAS (Matrix Authentication Service) Dockerfile - Railway Template
# ============================================================================
# This Dockerfile builds a production-ready MAS instance that uses
# environment variables for all configuration.
#
# Environment Variables Required:
# - MAS_PGHOST, MAS_PGPORT, MAS_PGUSER, MAS_PGPASSWORD, MAS_PGDATABASE
# - MAS_PUBLIC_BASE (Public URL)
# - MAS_MATRIX_HOMESERVER, MAS_MATRIX_ENDPOINT
# - MAS_MATRIX_SECRET, MAS_CLIENT_SECRET
# - MAS_ENCRYPTION_SECRET (128-char hex)
# - MAS_SIGNING_KEY (EC private key in PEM format)
# ============================================================================

FROM ghcr.io/matrix-org/matrix-authentication-service:latest

# Install envsubst for environment variable substitution
USER root
RUN apt-get update && \
    apt-get install -y gettext-base postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Create configuration directory
RUN mkdir -p /config && chown mas:mas /config

# Copy configuration template and entrypoint
COPY --chown=mas:mas config.yaml.template /config/config.yaml.template
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Switch back to MAS user
USER mas

# Expose MAS port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Use custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
