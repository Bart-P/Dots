#!/bin/bash
# Path to your Rofi theme file
THEME="$HOME/.config/rofi/themes/launcher.rasi"

# Launch rofi in drun mode with custom theme
rofi -show drun -p "App" -theme "$THEME"
