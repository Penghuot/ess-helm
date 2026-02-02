FROM ghcr.io/matrix-org/matrix-authentication-service:latest

USER root
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

COPY MAS-service/config.yaml.template /config.yaml.template
COPY MAS-service/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
