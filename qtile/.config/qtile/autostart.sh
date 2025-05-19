#!/bin/bash

blueman-applet &
nm-applet &
picom &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
greenclip daemon &
volctl &

# So the Screen does not switch off while watching something...
xset -dpms        # Disable Display Power Management System (DPMS)
xset s off        # Disable the screen saver
xset s noblank    # Prevent the screen from going blank
