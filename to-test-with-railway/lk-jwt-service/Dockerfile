# LiveKit JWT Service Dockerfile
FROM ghcr.io/element-hq/lk-jwt-service:latest

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
