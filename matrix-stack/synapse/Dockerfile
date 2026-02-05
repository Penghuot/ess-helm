FROM matrixdotorg/synapse:latest

COPY homeserver.template.yaml /data/homeserver.template.yaml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
