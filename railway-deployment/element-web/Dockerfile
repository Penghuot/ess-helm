FROM vectorim/element-web:latest

COPY config.json /app/config.json

EXPOSE 80

# Ensure nginx can read the config
RUN chmod 644 /app/config.json

# Use the entrypoint from the base image
CMD ["nginx", "-g", "daemon off;"]
