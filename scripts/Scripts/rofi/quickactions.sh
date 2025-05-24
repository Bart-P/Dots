#!/bin/bash

THEME="$HOME/.config/rofi/themes/launcher.rasi"

CHOICE=$(printf "[n]-Notes\n[d]-Downloads\n[p]-Projects\n[m]-Music" | rofi -dmenu -matching fuzzy -p "Quick Actions" -theme "$THEME")

case "$CHOICE" in
    "[n]-Notes")
        SESSION="notes"
        NOTE_DIR="$HOME/Dokumente/Brain2.0"

        tmux has-session -t "$SESSION" 2>/dev/null
        if [ $? != 0 ]; then
          tmux new-session -ds "$SESSION" -c "$NOTE_DIR"
        fi

        kitty -e tmux attach -t "$SESSION" \; send-keys "nvim ." C-m
        ;;

    "[d]-Downloads")
        pcmanfm "$HOME/Downloads"
        ;;

    "[p]-Projects")
        PROJECT_DIR="$HOME/Code"
        SESSION=$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | rofi -dmenu -p "Projects" -theme "$THEME")
        [ -z "$SESSION" ] && exit

        tmux has-session -t "$SESSION" 2>/dev/null
        if [ $? != 0 ]; then
            tmux new-session -ds "$SESSION" -c "$PROJECT_DIR/$SESSION"
        fi

        kitty -e tmux attach -t "$SESSION"
        ;;

    "[m]-Music")
        kitty -e ncmpcpp
        ;;
esac
