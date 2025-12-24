#!/bin/bash

declare -A menu_options
menu_options=(
    "   Log Out"    "swaymsg exit"
    "   Lock"    "swaylock"
    "   Suspend"    "systemctl suspend"
    "   Hibernate"  "systemctl hibernate"
    "   Reboot"     "systemctl reboot"
    "   Shutdown"   "systemctl poweroff"
)

options=$(printf "%s\n" "${!menu_options[@]}")

choice=$(echo -e "$options" | wofi -d -i -p 'Power Menu' -W 200 -H 175 -k /dev/null)

if [[ -n "$choice" && -n "${menu_options[$choice]}" ]]; then
    action="${menu_options[$choice]}"
    eval "$action"
fi
