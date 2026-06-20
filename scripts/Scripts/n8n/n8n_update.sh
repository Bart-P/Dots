#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/home/bp/Dots/docker/n8n"
COMPOSE_FILE="$COMPOSE_DIR/compose.yml"
DATA_PARENT="/var/lib/n8n"
DATA_DIR_NAME=".n8n"
BACKUP_DIR="/home/bp/Backups/n8n"
BACKUP_SCRIPT="/home/bp/Dots/scripts/Scripts/n8n/n8n_backup.sh"
N8N_URL="http://127.0.0.1:5678"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

TARGET_VERSION="${1:-}"
COMPOSE_BACKUP_FILE="$BACKUP_DIR/compose.yml.$TIMESTAMP.bak"
DATA_BACKUP_FILE=""
BACKUP_OUTPUT_FILE=""
RESTORE_DATA_ON_ROLLBACK="false"

usage() {
  echo "Usage: $0 <n8n-version>"
  echo "Example: $0 2.26.7"
}

wait_for_n8n() {
  for _ in {1..180}; do
    if curl -fsS "$N8N_URL" >/dev/null 2>&1; then
      return 0
    fi

    sleep 2
  done

  return 1
}

cleanup_temp_files() {
  if [ -n "$BACKUP_OUTPUT_FILE" ]; then
    rm -f "$BACKUP_OUTPUT_FILE"
  fi
}

trap cleanup_temp_files EXIT

rollback_and_exit() {
  set +e

  echo ""
  echo "Upgrade failed. Rolling back to n8n $CURRENT_VERSION."

  cd "$COMPOSE_DIR" || exit 1
  docker compose down

  if [ -f "$COMPOSE_BACKUP_FILE" ]; then
    cp "$COMPOSE_BACKUP_FILE" "$COMPOSE_FILE"
    echo "Restored compose file: $COMPOSE_FILE"
  else
    echo "Compose backup not found: $COMPOSE_BACKUP_FILE"
  fi

  if [ "$RESTORE_DATA_ON_ROLLBACK" = "true" ]; then
    if [ -z "$DATA_BACKUP_FILE" ] || [ ! -f "$DATA_BACKUP_FILE" ]; then
      echo "Data backup not available; cannot safely restore data automatically."
      echo "Expected backup: ${DATA_BACKUP_FILE:-unknown}"
      exit 1
    fi

    FAILED_DATA_DIR="$DATA_PARENT/${DATA_DIR_NAME}.failed-update-$TIMESTAMP"

    if [ -d "$DATA_PARENT/$DATA_DIR_NAME" ]; then
      sudo mv "$DATA_PARENT/$DATA_DIR_NAME" "$FAILED_DATA_DIR"
      echo "Moved upgraded data aside: $FAILED_DATA_DIR"
    fi

    sudo tar --xattrs --acls --numeric-owner -xzf "$DATA_BACKUP_FILE" -C "$DATA_PARENT"
    echo "Restored data backup: $DATA_BACKUP_FILE"
  fi

  docker compose up -d

  echo "Waiting for rolled-back n8n at $N8N_URL..."
  if wait_for_n8n; then
    echo "Rollback complete. n8n $CURRENT_VERSION is running: $N8N_URL"
  else
    echo "Rollback start failed. Recent logs:"
    docker compose logs --tail=120
  fi

  exit 1
}

if [ -z "$TARGET_VERSION" ]; then
  usage
  exit 1
fi

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

if ! printf '%s' "$TARGET_VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-.][A-Za-z0-9]+)*$'; then
  echo "Refusing target version that does not look like a pinned n8n version: $TARGET_VERSION"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is not installed."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is not installed."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running."
  echo "Start it with: sudo systemctl start docker"
  exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Compose file not found: $COMPOSE_FILE"
  exit 1
fi

if [ ! -f "$BACKUP_SCRIPT" ]; then
  echo "Backup script not found: $BACKUP_SCRIPT"
  exit 1
fi

CURRENT_IMAGE_LINE="$({ grep -E '^[[:space:]]*image:[[:space:]]*docker\.n8n\.io/n8nio/n8n:' "$COMPOSE_FILE" | sed -n '1p'; } || true)"
CURRENT_IMAGE="${CURRENT_IMAGE_LINE#*image:}"
CURRENT_IMAGE="${CURRENT_IMAGE//[[:space:]]/}"
CURRENT_VERSION="${CURRENT_IMAGE##*:}"

if [ -z "$CURRENT_IMAGE_LINE" ] || [ "$CURRENT_VERSION" = "$CURRENT_IMAGE" ]; then
  echo "Could not read current n8n image version from: $COMPOSE_FILE"
  exit 1
fi

if [ "$CURRENT_VERSION" = "$TARGET_VERSION" ]; then
  echo "n8n is already pinned to $TARGET_VERSION."
  exit 0
fi

mkdir -p "$BACKUP_DIR"

echo "Current n8n version: $CURRENT_VERSION"
echo "Target n8n version:  $TARGET_VERSION"
echo "Creating pre-upgrade data backup..."

BACKUP_OUTPUT_FILE="$(mktemp)"

if ! bash "$BACKUP_SCRIPT" | tee "$BACKUP_OUTPUT_FILE"; then
  echo "Pre-upgrade backup failed. Upgrade was not started."
  exit 1
fi

DATA_BACKUP_FILE="$({ grep -E '^/.*/n8n-backup-[0-9]{8}-[0-9]{6}\.tar\.gz$' "$BACKUP_OUTPUT_FILE" | sed -n '$p'; } || true)"

if [ -z "$DATA_BACKUP_FILE" ] || [ ! -f "$DATA_BACKUP_FILE" ]; then
  echo "Could not identify the data backup file from backup output."
  exit 1
fi

cp "$COMPOSE_FILE" "$COMPOSE_BACKUP_FILE"
echo "Compose backup created: $COMPOSE_BACKUP_FILE"

cd "$COMPOSE_DIR"

echo "Stopping n8n before upgrade..."
docker compose down

echo "Pulling n8n $TARGET_VERSION..."
if ! docker pull "docker.n8n.io/n8nio/n8n:$TARGET_VERSION"; then
  rollback_and_exit
fi

if ! sed -i "s#docker.n8n.io/n8nio/n8n:$CURRENT_VERSION#docker.n8n.io/n8nio/n8n:$TARGET_VERSION#" "$COMPOSE_FILE"; then
  rollback_and_exit
fi

if ! grep -Eq "^[[:space:]]*image:[[:space:]]*docker\.n8n\.io/n8nio/n8n:$TARGET_VERSION$" "$COMPOSE_FILE"; then
  echo "Compose file was not updated to n8n $TARGET_VERSION."
  rollback_and_exit
fi

echo "Starting n8n $TARGET_VERSION..."
RESTORE_DATA_ON_ROLLBACK="true"
if ! docker compose up -d; then
  rollback_and_exit
fi

echo "Waiting for n8n at $N8N_URL..."
if ! wait_for_n8n; then
  echo "n8n $TARGET_VERSION did not become ready in time. Recent logs:"
  docker compose logs --tail=120
  rollback_and_exit
fi

echo "n8n updated successfully: $CURRENT_VERSION -> $TARGET_VERSION"
echo "URL: $N8N_URL"
echo "Data backup: $DATA_BACKUP_FILE"
echo "Compose backup: $COMPOSE_BACKUP_FILE"
