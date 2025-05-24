#!/bin/bash

THEME="$HOME/.config/rofi/themes/launcher.rasi"

CHOICE=$(printf "[s]-Shutdown\n[r]-Reboot\n[l]-Logout\n" | rofi -dmenu -matching fuzzy -p "Power Menu" -theme "$THEME")

case "$CHOICE" in
    "[s]-Shutdown")
        systemctl poweroff
        ;;

    "[r]-Reboot")
        reboot
        ;;

    "[l]-Logout")
        qtile cmd-obj -o cmd -f shutdown
        ;;
esac
