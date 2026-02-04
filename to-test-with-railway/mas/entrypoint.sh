#!/bin/bash
set -euo pipefail

# Required env vars
: "${MAS_PUBLIC_BASE:?Must set MAS_PUBLIC_BASE}"
: "${MAS_DATABASE_URI:?Must set MAS_DATABASE_URI}"
: "${MAS_MATRIX_HOMESERVER:?Must set MAS_MATRIX_HOMESERVER}"
: "${MAS_MATRIX_ENDPOINT:?Must set MAS_MATRIX_ENDPOINT}"
: "${MAS_MATRIX_SHARED_SECRET:?Must set MAS_MATRIX_SHARED_SECRET}"
: "${MAS_CLIENT_ID:?Must set MAS_CLIENT_ID}"
: "${MAS_CLIENT_SECRET:?Must set MAS_CLIENT_SECRET}"
: "${MAS_ENCRYPTION_KEY:?Must set MAS_ENCRYPTION_KEY}"
: "${MAS_SIGNING_KEY:?Must set MAS_SIGNING_KEY (PEM, multi-line)}"
: "${MAS_EMAIL_DOMAIN:?Must set MAS_EMAIL_DOMAIN}"

# Indent PEM key for YAML block and write to temp file
printf '%s\n' "${MAS_SIGNING_KEY}" | sed 's/^/        /' > /tmp/signing_key.txt

# Render final config.yaml into /app/config.yaml
sed \
  -e "s#{{MAS_PUBLIC_BASE}}#${MAS_PUBLIC_BASE}#g" \
  -e "s#{{MAS_DATABASE_URI}}#${MAS_DATABASE_URI}#g" \
  -e "s#{{MAS_MATRIX_HOMESERVER}}#${MAS_MATRIX_HOMESERVER}#g" \
  -e "s#{{MAS_MATRIX_ENDPOINT}}#${MAS_MATRIX_ENDPOINT}#g" \
  -e "s#{{MAS_MATRIX_SHARED_SECRET}}#${MAS_MATRIX_SHARED_SECRET}#g" \
  -e "s#{{MAS_CLIENT_ID}}#${MAS_CLIENT_ID}#g" \
  -e "s#{{MAS_CLIENT_SECRET}}#${MAS_CLIENT_SECRET}#g" \
  -e "s#{{MAS_ENCRYPTION_KEY}}#${MAS_ENCRYPTION_KEY}#g" \
  -e "s#{{MAS_EMAIL_DOMAIN}}#${MAS_EMAIL_DOMAIN}#g" \
  /app/config.template.yaml \
| sed "/{{MAS_SIGNING_KEY_INDENTED}}/{
    r /tmp/signing_key.txt
    d
}" > /app/config.yaml

export MAS_CONFIG_PATH=/app/config.yaml


# Start the MAS server with our generated config
exec mas-cli server

