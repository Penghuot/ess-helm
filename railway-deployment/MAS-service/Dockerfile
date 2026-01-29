FROM ghcr.io/matrix-org/matrix-authentication-service:latest

# Copy configuration
COPY config.yaml /config.yaml

# Set config path for runtime
ENV MAS_CONFIG_PATH=/config.yaml

# Expose port
EXPOSE 8080

# Don't run any validation at build time, let the service handle it at runtime
