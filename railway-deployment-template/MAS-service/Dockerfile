# ============================================================================
# MAS (Matrix Authentication Service) Dockerfile - Railway Template
# ============================================================================
# Environment variables set in Railway:
# - MAS_PUBLIC_BASE, DATABASE_URL (Railway internal), MAS_MATRIX_HOMESERVER,
# - MAS_MATRIX_ENDPOINT, MAS_MATRIX_SECRET, MAS_CLIENT_SECRET,
# - MAS_ENCRYPTION_SECRET, MAS_SIGNING_KEY
# ============================================================================

FROM ghcr.io/matrix-org/matrix-authentication-service:latest

# Copy configuration template and entrypoint
COPY MAS-service/config.yaml.template /config.yaml.template
COPY --chmod=755 MAS-service/entrypoint.sh /entrypoint.sh

# Expose MAS port
EXPOSE 8080

# Use custom entrypoint to substitute env vars
ENTRYPOINT ["/entrypoint.sh"]
