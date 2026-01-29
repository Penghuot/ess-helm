FROM ghcr.io/matrix-org/matrix-authentication-service:latest

# Copy configuration
COPY config.yaml /config.yaml

# Expose port (MAS typically uses 8080)
EXPOSE 8080

# Start the MAS server
CMD ["mas-cli", "server", "-c", "/config.yaml"]
