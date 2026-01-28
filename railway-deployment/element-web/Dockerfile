FROM vectorim/element-web:v1.12.9

# Install envsubst for environment variable substitution
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends gettext-base curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy config template
COPY config.json /tmp/config.json.template

# Create startup script that substitutes env vars
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'set -e' >> /docker-entrypoint.sh && \
    echo 'envsubst < /tmp/config.json.template > /app/config.json' >> /docker-entrypoint.sh && \
    echo 'exec nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Switch to nginx user
USER 101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]