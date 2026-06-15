-- Re-apply game mode on every reload in case gamemoded is active
hl.exec_cmd("$HOME/.config/hypr/custom/scripts/gamemode-reload-check.sh")

-- Apply Bing daily wallpaper on startup if enabled and not yet downloaded today
hl.on("hyprland.start", function()
    hl.exec_cmd("$HOME/.config/quickshell/ii/scripts/colors/random/random_bing_wall.sh")
end)
