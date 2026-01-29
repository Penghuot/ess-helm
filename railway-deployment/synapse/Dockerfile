FROM matrixdotorg/synapse:latest

# Copy the generated synapse config
COPY synapse-config /data

# Copy your custom homeserver.yaml to override defaults
COPY homeserver.yaml /data/homeserver.yaml

# Expose port 8008
EXPOSE 8008

# Run synapse
CMD ["run"]

