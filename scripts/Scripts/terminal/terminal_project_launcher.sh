#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$HOME/Code"
SESSION_PATH="$(
  find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -type d | fzf
)" || exit 0

NAME="$(basename "$SESSION_PATH")"
NEW_SESSION=0

if ! tmux has-session -t "$NAME" 2>/dev/null; then
  tmux new-session -d -s "$NAME" -c "$SESSION_PATH"
  NEW_SESSION=1

  if [[ -x "$SESSION_PATH/scripts/dev-tmux.sh" ]]; then
    tmux send-keys -t "$NAME:1" "./scripts/dev-tmux.sh" C-m
  fi
fi

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$NAME"
else
  tmux attach -t "$NAME"
fi
