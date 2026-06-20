#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/home/bp/Dots/docker/n8n"
DATA_PARENT="/var/lib/n8n"
DATA_DIR_NAME=".n8n"
BACKUP_DIR="/home/bp/Backups/n8n"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/n8n-backup-$TIMESTAMP.tar.gz"

WAS_RUNNING="false"
STARTED_AGAIN="false"

restart_n8n_if_needed() {
  if [ "$WAS_RUNNING" = "true" ] && [ "$STARTED_AGAIN" = "false" ]; then
    cd "$COMPOSE_DIR"
    docker compose up -d
    STARTED_AGAIN="true"
  fi
}

trap restart_n8n_if_needed EXIT

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

if [ ! -d "$DATA_PARENT/$DATA_DIR_NAME" ]; then
  echo "n8n data directory not found: $DATA_PARENT/$DATA_DIR_NAME"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

if docker ps --filter "name=^/n8n$" --filter "status=running" --format '{{.Names}}' | grep -qx 'n8n'; then
  WAS_RUNNING="true"
  cd "$COMPOSE_DIR"
  docker compose down
fi

sudo tar --xattrs --acls --numeric-owner -czf "$BACKUP_FILE" -C "$DATA_PARENT" "$DATA_DIR_NAME"
sudo chown bp:bp "$BACKUP_FILE"

tar -tzf "$BACKUP_FILE" | grep -qx ".n8n/config"
tar -tzf "$BACKUP_FILE" | grep -qx ".n8n/database.sqlite"

if ! tar -tzf "$BACKUP_FILE" | grep -qx ".n8n/database.sqlite-wal"; then
  echo "Warning: .n8n/database.sqlite-wal not found in backup."
fi

echo "Backup created:"
echo "$BACKUP_FILE"

echo "Checksum:"
sha256sum "$BACKUP_FILE"

restart_n8n_if_needed
trap - EXIT
