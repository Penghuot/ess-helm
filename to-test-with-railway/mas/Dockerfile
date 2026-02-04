# Stage 1: wrapper
FROM debian:bookworm-slim AS wrapper
RUN apt-get update && apt-get install -y --no-install-recommends bash sed ca-certificates
WORKDIR /app
COPY config.template.yaml entrypoint.sh ./
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

# Stage 2: MAS image (distroless)
FROM ghcr.io/element-hq/matrix-authentication-service:latest
WORKDIR /app
COPY --from=wrapper /app/entrypoint.sh /app/entrypoint.sh
COPY --from=wrapper /app/config.template.yaml /app/config.template.yaml
COPY --from=wrapper /bin/bash /bin/bash
COPY --from=wrapper /bin/sed /bin/sed
COPY --from=wrapper /usr/lib/* /usr/lib/

ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
