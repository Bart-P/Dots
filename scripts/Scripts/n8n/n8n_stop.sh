#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/home/bp/Dots/docker/n8n"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running."
  exit 1
fi

if [ ! -f "$COMPOSE_DIR/compose.yml" ]; then
  echo "Compose file not found: $COMPOSE_DIR/compose.yml"
  exit 1
fi

cd "$COMPOSE_DIR"

docker compose down

echo "n8n stopped."
