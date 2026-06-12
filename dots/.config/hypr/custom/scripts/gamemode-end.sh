#!/bin/bash
# Called by gamemoded when the last game unregisters. Resets overrides so the base
# config values take effect — no hardcoded restore values needed.
python3 "$HOME/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py" \
    --file "$HOME/.config/hypr/hyprland/shellOverrides/main.lua" \
    --reset "animations:enabled" \
    --reset "decoration:shadow:enabled" \
    --reset "decoration:blur:enabled" \
    --reset "general:gaps_in" \
    --reset "general:gaps_out" \
    --reset "general:border_size" \
    --reset "decoration:rounding" \
    --reset "general:allow_tearing"
