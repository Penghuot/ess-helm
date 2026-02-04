FROM livekit/livekit-server:v1.9.1
COPY livekit.production.yaml /etc/livekit.yaml
EXPOSE 7880 7881 5349 3478
CMD ["/livekit-server", "--config", "/etc/livekit.yaml"]
