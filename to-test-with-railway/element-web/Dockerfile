FROM vectorim/element-web:v1.11.86

WORKDIR /app

COPY config.template.json /app/config.template.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
