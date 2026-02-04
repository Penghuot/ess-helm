# Stage 1: builder
FROM alpine:latest AS builder
RUN apk add --no-cache gettext
COPY config.yaml.template /config.yaml.template

# Render config.yaml at build time
RUN envsubst < /config.yaml.template > /config.yaml

# Stage 2: MAS runtime
FROM ghcr.io/matrix-org/matrix-authentication-service:latest
COPY --from=builder /config.yaml /config.yaml
ENV MAS_CONFIG_PATH=/config.yaml

EXPOSE 8080
ENTRYPOINT ["mas-cli", "server", "-c", "/config.yaml"]
