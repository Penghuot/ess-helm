# Element Call Dockerfile for Railway
FROM vectorim/element-call:latest

# Copy configuration files
COPY config.template.json /app/config.template.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
