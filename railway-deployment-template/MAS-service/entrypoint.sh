#!/bin/sh
set -e

echo "Generating config.yaml from template..."
envsubst < /config.yaml.template > /config.yaml
echo "✓ config.yaml generated"

exec mas-cli server -c /config.yaml
