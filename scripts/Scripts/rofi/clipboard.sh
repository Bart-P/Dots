#!/bin/bash
# Path to your Rofi theme file
THEME="$HOME/.config/rofi/themes/launcher.rasi"

# Launch rofi in drun mode with custom theme
rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}' -theme "$THEME"
