FROM ghcr.io/matrix-org/matrix-authentication-service:latest

# Copy configuration template
COPY MAS-service/config.yaml.template /config.yaml.template

# Set config path for runtime
ENV MAS_CONFIG_PATH=/config.yaml.template

# Expose MAS port
EXPOSE 8080

# Use the default entrypoint from the MAS image
