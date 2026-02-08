FROM livekit/livekit-server:latest

COPY user-config.yaml /etc/livekit/user-config.yaml

EXPOSE 7880

CMD ["livekit-server", "--config", "/etc/livekit/user-config.yaml"]
