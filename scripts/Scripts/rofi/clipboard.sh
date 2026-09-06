#!/bin/bash

THEME="$HOME/.config/rofi/themes/launcher.rasi"

selection=$(cliphist list | rofi -dmenu -matching fuzzy -p "Clipboard" -theme "$THEME")
[ -z "$selection" ] && exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
