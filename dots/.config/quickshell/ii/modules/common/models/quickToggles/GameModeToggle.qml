import QtQuick
import qs.modules.common.models.hyprland
import qs.services

QuickToggleModel {
    id: root
    name: Translation.tr("Game mode")
    toggled: !confOpt.value
    icon: "gamepad"

    function enableGameMode() {
        HyprlandConfig.setMany({
            "animations:enabled": 0,
            "decoration:shadow:enabled": 0,
            "decoration:blur:enabled": 0,
            "general:gaps_in": 0,
            "general:gaps_out": 0,
            "general:border_size": 1,
            "decoration:rounding": 0,
            "general:allow_tearing": 1
        });
    }

    function disableGameMode() {
        HyprlandConfig.resetMany([
            "animations:enabled",
            "decoration:shadow:enabled",
            "decoration:blur:enabled",
            "general:gaps_in",
            "general:gaps_out",
            "general:border_size",
            "decoration:rounding",
            "general:allow_tearing",
        ]);
    }

    // Auto-detection is handled by gamemoded hooks (gamemode-start/end.sh) which write
    // directly to shellOverrides/main.lua. Hyprland auto-reloads on file change, which
    // updates confOpt.value and keeps this toggle's displayed state in sync.
    mainAction: () => {
        root.toggled = !root.toggled;
        if (root.toggled) {
            root.enableGameMode();
        } else {
            root.disableGameMode();
        }
    }

    HyprlandConfigOption {
        id: confOpt
        key: "animations:enabled"
    }

    tooltipText: Translation.tr("Game mode")
}
