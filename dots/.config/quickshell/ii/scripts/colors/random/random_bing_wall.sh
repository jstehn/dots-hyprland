#!/usr/bin/env bash

get_pictures_dir() {
    if command -v xdg-user-dir &> /dev/null; then
        xdg-user-dir PICTURES
        return
    fi

    local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"
    if [ -f "$config_file" ]; then
        local pictures_path
        # shellcheck source=/dev/null
        pictures_path=$(source "$config_file" >/dev/null 2>&1; echo "$XDG_PICTURES_DIR")
        echo "${pictures_path/#\$HOME/$HOME}"
        return
    fi

    echo "$HOME/Pictures"
}

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
PICTURES_DIR=$(get_pictures_dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

force=false
[[ "$1" == "--force" ]] && force=true

illogicalImpulseConfigPath="$HOME/.config/illogical-impulse/config.json"
enabled=$(jq -r '.background.bingDailyWallpaper.enabled // false' "$illogicalImpulseConfigPath" 2>/dev/null)
[[ "$enabled" != "true" ]] && exit 0

userAgent=$(jq -r '.networking.userAgent // empty' "$illogicalImpulseConfigPath" 2>/dev/null)

BING_DIR="$PICTURES_DIR/Wallpapers/Bing"
mkdir -p "$BING_DIR"

downloadPath="$BING_DIR/bing-$(date +%Y-%m-%d).jpg"

# Skip download if today's image already exists and is non-empty, unless forced
[[ "$force" == "false" && -s "$downloadPath" ]] && {
    "$SCRIPT_DIR/../switchwall.sh" --image "$downloadPath"
    exit 0
}

response=$(curl -A "$userAgent" -sf "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US")
imageUrl="https://www.bing.com$(echo "$response" | jq -r '.images[0].urlbase')_UHD.jpg"
title=$(echo "$response" | jq -r '.images[0].title // "Bing Daily Wallpaper"')
caption=$(echo "$response" | jq -r '.images[0].copyright // ""')

curl -A "$userAgent" -sf "$imageUrl" -o "$downloadPath" || {
    rm -f "$downloadPath"
    exit 1
}

# Keep only the 100 most recent images (YYYY-MM-DD names sort correctly without -t)
find "$BING_DIR" -maxdepth 1 -name 'bing-*.jpg' | sort -r | tail -n +101 | xargs -r rm --

"$SCRIPT_DIR/../switchwall.sh" --image "$downloadPath"

notify-send --app-name="Bing Daily" --icon="$downloadPath" "$title" "$caption"
