#!/bin/sh
# Render config.yaml from env vars at runtime
envsubst < /config.yaml.template > /config.yaml

exec mas-cli server -c /config.yaml