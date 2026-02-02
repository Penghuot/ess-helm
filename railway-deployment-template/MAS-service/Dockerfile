FROM ghcr.io/matrix-org/matrix-authentication-service:latest

RUN apk add --no-cache gettext

COPY MAS-service/config.yaml.template /config.yaml.template
COPY MAS-service/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE $PORT

ENTRYPOINT ["/entrypoint.sh"]