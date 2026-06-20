#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/home/bp/Dots/docker/n8n"
N8N_URL="http://127.0.0.1:5678"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running."
  echo "Start it with: sudo systemctl start docker"
  exit 1
fi

if [ ! -f "$COMPOSE_DIR/compose.yml" ]; then
  echo "Compose file not found: $COMPOSE_DIR/compose.yml"
  exit 1
fi

cd "$COMPOSE_DIR"

docker compose up -d

echo "Waiting for n8n at $N8N_URL..."

for _ in {1..30}; do
  if curl -fsS "$N8N_URL" >/dev/null 2>&1; then
    echo "n8n is running: $N8N_URL"
    exit 0
  fi

  sleep 1
done

echo "n8n did not become ready in time."
echo "Recent logs:"
docker compose logs --tail=80
exit 1
