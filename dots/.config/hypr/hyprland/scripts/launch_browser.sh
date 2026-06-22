#!/usr/bin/env bash
# Launch the user's configured default browser (xdg-settings); fall back to the
# first available browser from the provided list if no default is set.
default="$(xdg-settings get default-web-browser 2>/dev/null)"
if [[ -n "$default" ]] && command -v gtk-launch >/dev/null 2>&1; then
    gtk-launch "${default%.desktop}" && exit
fi
exec "$(dirname "$0")/launch_first_available.sh" "$@"
