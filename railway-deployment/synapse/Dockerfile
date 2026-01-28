FROM matrixdotorg/synapse:v1.118.0

COPY homeserver.yaml /data/homeserver.yaml
COPY log.config.yaml /data/log.config.yaml

RUN mkdir -p /data/media_store && \
    chown -R 991:991 /data/media_store

EXPOSE 8008
