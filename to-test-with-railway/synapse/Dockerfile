FROM matrixdotorg/synapse:latest
# Install MAS password provider

USER root
# Install git so pip can fetch from GitHub
# RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
# # Install MAS password provider directly from GitHub
# RUN pip install git+https://github.com/matrix-org/matrix-authentication-service.git#subdirectory=crates/matrix-auth-provider-python
# Create media store directory
RUN mkdir -p /data/media_store

WORKDIR /app

# Copy template config, log config, and entrypoint
COPY homeserver.template.yaml /app/homeserver.template.yaml
COPY synapse.log.config /app/synapse.log.config
COPY registration.railway.production.yml /app/registration.railway.production.yml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && chown -R 991:991 /data && chmod -R 755 /data

USER 991

EXPOSE 8008

ENTRYPOINT ["/entrypoint.sh"]