import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Bing Daily")
    icon: "partly_cloudy_day"
    toggled: Config.options.background?.bingDailyWallpaper?.enabled ?? false
    statusText: toggled ? Translation.tr("Active") : Translation.tr("Inactive")
    tooltipText: Translation.tr("Bing daily wallpaper")

    mainAction: () => {
        const enabling = !toggled
        Config.options.background.bingDailyWallpaper.enabled = enabling
        if (enabling) {
            Quickshell.execDetached(["bash", "-c",
                "$HOME/.config/quickshell/ii/scripts/colors/random/random_bing_wall.sh --force"])
        }
    }
}
