FROM matrixdotorg/synapse:latest
COPY homeserver.yaml /synapse/config/homeserver.yaml
CMD ["python", "-m", "synapse.app.homeserver", "--config-path", "/synapse/config/homeserver.yaml"]
