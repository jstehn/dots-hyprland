#!/bin/bash
# Called by gamemoded when a game registers. Writes overrides to shellOverrides/main.lua;
# Hyprland detects the file change and auto-reloads — no hyprctl reload needed.
python3 "$HOME/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py" \
    --file "$HOME/.config/hypr/hyprland/shellOverrides/main.lua" \
    --set "animations:enabled"        "0" \
    --set "decoration:shadow:enabled" "0" \
    --set "decoration:blur:enabled"   "0" \
    --set "general:gaps_in"           "0" \
    --set "general:gaps_out"          "0" \
    --set "general:border_size"       "1" \
    --set "decoration:rounding"       "0" \
    --set "general:allow_tearing"     "1"
