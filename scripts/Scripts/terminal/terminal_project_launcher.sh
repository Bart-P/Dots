#!/bin/bash

PROJECT_DIR="$HOME/Code"
DOTS_DIR="$HOME/Dots"
SESSION=$({ 
    find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -type d 
} | fzf) || exit

NAME=$(basename $SESSION)

tmux has-session -t "$NAME" 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -ds "$NAME" -c "$PROJECT_DIR/$NAME"
fi

tmux attach -t "$NAME"
