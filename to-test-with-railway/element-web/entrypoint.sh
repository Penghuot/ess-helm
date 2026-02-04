#!/usr/bin/env bash
set -euo pipefail

: "${ELEMENT_DEFAULT_HS:?Must set ELEMENT_DEFAULT_HS}"

ELEMENT_DEFAULT_SERVER_NAME="${ELEMENT_DEFAULT_SERVER_NAME:-matrix-railway}"
ELEMENT_DEFAULT_THEME="${ELEMENT_DEFAULT_THEME:-light}"

sed \
  -e "s#{{ELEMENT_DEFAULT_HS}}#${ELEMENT_DEFAULT_HS}#g" \
  -e "s#{{ELEMENT_DEFAULT_SERVER_NAME}}#${ELEMENT_DEFAULT_SERVER_NAME}#g" \
  -e "s#{{ELEMENT_DEFAULT_THEME}}#${ELEMENT_DEFAULT_THEME}#g" \
  /app/config.template.json > /app/config.json

# Most element-web images use nginx; adjust if docs say otherwise.
exec nginx -g "daemon off;"