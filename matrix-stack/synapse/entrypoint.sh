#!/usr/bin/env bash
set -euo pipefail

: "${SYNAPSE_SERVER_NAME:?Must set SYNAPSE_SERVER_NAME}"
: "${SYNAPSE_PUBLIC_BASEURL:?Must set SYNAPSE_PUBLIC_BASEURL}"
: "${SYNAPSE_DB_USER:?Must set SYNAPSE_DB_USER}"
: "${SYNAPSE_DB_PASSWORD:?Must set SYNAPSE_DB_PASSWORD}"
: "${SYNAPSE_DB_HOST:?Must set SYNAPSE_DB_HOST}"
: "${SYNAPSE_DB_NAME:?Must set SYNAPSE_DB_NAME}"
: "${SYNAPSE_MACAROON_SECRET_KEY:?Must set SYNAPSE_MACAROON_SECRET_KEY}"
: "${SYNAPSE_FORM_SECRET:?Must set SYNAPSE_FORM_SECRET}"
: "${SYNAPSE_REGISTRATION_SECRET:?Must set SYNAPSE_REGISTRATION_SECRET}"

SYNAPSE_DB_PORT="${SYNAPSE_DB_PORT:-5432}"

mkdir -p /data /data/media_store

sed \
  -e "s#{{SYNAPSE_SERVER_NAME}}#${SYNAPSE_SERVER_NAME}#g" \
  -e "s#{{SYNAPSE_PUBLIC_BASEURL}}#${SYNAPSE_PUBLIC_BASEURL}#g" \
  -e "s#{{SYNAPSE_DB_USER}}#${SYNAPSE_DB_USER}#g" \
  -e "s#{{SYNAPSE_DB_PASSWORD}}#${SYNAPSE_DB_PASSWORD}#g" \
  -e "s#{{SYNAPSE_DB_HOST}}#${SYNAPSE_DB_HOST}#g" \
  -e "s#{{SYNAPSE_DB_PORT}}#${SYNAPSE_DB_PORT}#g" \
  -e "s#{{SYNAPSE_DB_NAME}}#${SYNAPSE_DB_NAME}#g" \
  -e "s#{{SYNAPSE_MACAROON_SECRET_KEY}}#${SYNAPSE_MACAROON_SECRET_KEY}#g" \
  -e "s#{{SYNAPSE_FORM_SECRET}}#${SYNAPSE_FORM_SECRET}#g" \
  -e "s#{{SYNAPSE_REGISTRATION_SECRET}}#${SYNAPSE_REGISTRATION_SECRET}#g" \
  /data/homeserver.template.yaml > /data/homeserver.yaml

if [[ ! -f /data/synapse.log.config ]]; then
  cat > /data/synapse.log.config << 'EOF'
version: 1
formatters:
  precise:
    format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(message)s'
handlers:
  console:
    class: logging.StreamHandler
    formatter: precise
loggers:
  synapse:
    level: INFO
root:
  level: INFO
  handlers: [console]
EOF
fi

python -m synapse.app.homeserver \
  --config-path /data/homeserver.yaml \
  --generate-keys

exec python -m synapse.app.homeserver --config-path /data/homeserver.yaml
