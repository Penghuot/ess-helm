#!/usr/bin/env bash
set -euo pipefail

# Required env vars from Railway
: "${SYNAPSE_SERVER_NAME:?Must set SYNAPSE_SERVER_NAME}"           # e.g. synapse-1234.up.railway.app
: "${SYNAPSE_PUBLIC_BASEURL:?Must set SYNAPSE_PUBLIC_BASEURL}"     # e.g. https://synapse-1234.up.railway.app/
: "${SYNAPSE_DB_USER:?Must set SYNAPSE_DB_USER}"
: "${SYNAPSE_DB_PASSWORD:?Must set SYNAPSE_DB_PASSWORD}"
: "${SYNAPSE_DB_HOST:?Must set SYNAPSE_DB_HOST}"
: "${SYNAPSE_DB_NAME:?Must set SYNAPSE_DB_NAME}"
: "${SYNAPSE_MACAROON_SECRET_KEY:?Must set SYNAPSE_MACAROON_SECRET_KEY}"
: "${SYNAPSE_FORM_SECRET:?Must set SYNAPSE_FORM_SECRET}"
: "${MAS_PUBLIC_URL:?Must set MAS_PUBLIC_URL}"
: "${MAS_CLIENT_ID:?Must set MAS_CLIENT_ID}"
: "${MAS_CLIENT_SECRET:?Must set MAS_CLIENT_SECRET}"
: "${MAS_MATRIX_SHARED_SECRET:?Must set MAS_MATRIX_SHARED_SECRET}"

# Optional with defaults
SYNAPSE_DB_PORT="${SYNAPSE_DB_PORT:-5432}"
SYNAPSE_ENABLE_REGISTRATION="${SYNAPSE_ENABLE_REGISTRATION:-false}"
SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION="${SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION:-false}"

mkdir -p /data /data/media_store

# 1) Render homeserver.yaml from template
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
  -e "s#{{SYNAPSE_ENABLE_REGISTRATION}}#${SYNAPSE_ENABLE_REGISTRATION}#g" \
  -e "s#{{MAS_PUBLIC_URL}}#${MAS_PUBLIC_URL}#g" \
  -e "s#{{MAS_CLIENT_ID}}#${MAS_CLIENT_ID}#g" \
  -e "s#{{MAS_CLIENT_SECRET}}#${MAS_CLIENT_SECRET}#g" \
  -e "s#{{MAS_MATRIX_SHARED_SECRET}}#${MAS_MATRIX_SHARED_SECRET}#g" \
  -e "s#{{SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION}}#${SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION}#g" \
  /app/homeserver.template.yaml > /data/homeserver.yaml

# DEBUG: Print key sections from generated config
echo "=== DEBUG: Synapse Version ==="
python -m synapse.app.homeserver --version || echo "Version check failed"
echo ""
echo "=== DEBUG: Generated MSC3861 Config ==="
sed -n '/^experimental_features:/,/^app_service_config_files:/p' /data/homeserver.yaml || true
echo "=== DEBUG: Generated Appservice Config ==="
sed -n '/^app_service_config_files:/,+3p' /data/homeserver.yaml || true
echo "=== END DEBUG ==="

# 2) Copy generic log config into /data if not already there
if [[ ! -f /data/synapse.log.config ]]; then
  cp /app/synapse.log.config /data/synapse.log.config
fi

# 2b) Ensure appservice registration file exists in /data
if [[ -f /app/registration.railway.production.yml ]]; then
  registration_src="/app/registration.railway.production.yml"

  if grep -q '\${AS_TOKEN}' "$registration_src"; then
    : "${AS_TOKEN:?Must set AS_TOKEN when registration file uses \${AS_TOKEN}}"
  fi

  if grep -q '\${HS_TOKEN}' "$registration_src"; then
    : "${HS_TOKEN:?Must set HS_TOKEN when registration file uses \${HS_TOKEN}}"
  fi

  sed \
    -e 's#${AS_TOKEN}#'"${AS_TOKEN:-}"'#g' \
    -e 's#${HS_TOKEN}#'"${HS_TOKEN:-}"'#g' \
    "$registration_src" > /data/registration.railway.production.yml
elif [[ -f /data/registration.railway.production.yml ]]; then
  echo "INFO: Using existing /data/registration.railway.production.yml"
else
  echo "ERROR: registration file missing in both /app and /data"
  exit 1
fi

echo "=== DEBUG: Appservice Registration File ==="
ls -l /app/registration.railway.production.yml /data/registration.railway.production.yml 2>/dev/null || true
echo "=== END DEBUG ==="

# 3) Generate keys if missing
python -m synapse.app.homeserver \
  --config-path /data/homeserver.yaml \
  --generate-keys

# 4) Validate config before starting
echo "=== Validating Synapse config ==="
python -m synapse.config.homeserver --config-path /data/homeserver.yaml || {
  echo "ERROR: Config validation failed!"
  cat /data/homeserver.yaml
  exit 1
}

# 5) Start Synapse
exec python -m synapse.app.homeserver \
  --config-path /data/homeserver.yaml
