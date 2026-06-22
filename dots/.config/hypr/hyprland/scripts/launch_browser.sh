#!/usr/bin/env bash
# Launch the user's default browser, resolved the same way URLs are actually
# opened (the https:// scheme handler), since `xdg-settings
# get default-web-browser` can point at an unrelated PWA. Falls back to the
# first available browser from the provided list if no default is set.
default="$(xdg-mime query default x-scheme-handler/https 2>/dev/null)"
if [[ -n "$default" ]] && command -v gtk-launch >/dev/null 2>&1; then
    gtk-launch "${default%.desktop}" && exit
fi
exec "$(dirname "$0")/launch_first_available.sh" "$@"
