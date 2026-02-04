#!/bin/sh
envsubst < /config.yaml.template > /config.yaml
exec mas-cli server -c /config.yaml
