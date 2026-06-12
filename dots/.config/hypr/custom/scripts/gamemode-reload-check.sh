#!/bin/bash
# Run by Hyprland exec on every config reload.
# Re-applies game mode settings if gamemoded has active clients but they aren't
# already reflected in the running config (e.g. after a manual hyprctl reload).
#
# Loop-safety: if shellOverrides already has the settings, Hyprland will have
# loaded them from disk and getoption returns 0 → we skip the write entirely.

count=$(busctl --user get-property \
    com.feralinteractive.GameMode \
    /com/feralinteractive/GameMode \
    com.feralinteractive.GameMode ClientCount 2>/dev/null | awk '{print $2}')

[ -n "$count" ] && [ "$count" -gt 0 ] || exit 0

anim=$(hyprctl getoption animations:enabled -j 2>/dev/null \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('int', 1))" 2>/dev/null)

if [ "$anim" != "0" ]; then
    exec "$HOME/.config/hypr/custom/scripts/gamemode-start.sh"
fi
