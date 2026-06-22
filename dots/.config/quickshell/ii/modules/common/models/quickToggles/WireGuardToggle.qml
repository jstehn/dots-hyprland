import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("WireGuard")

    readonly property string unit: "wg-quick-wg0.service"

    toggled: false
    icon: "vpn_lock"

    mainAction: () => {
        if (toggled) {
            root.toggled = false
            Quickshell.execDetached(["systemctl", "stop", root.unit])
        } else {
            root.toggled = true
            Quickshell.execDetached(["systemctl", "start", root.unit])
        }
    }

    Process {
        id: checkActiveProc
        running: true
        command: ["systemctl", "is-active", root.unit]
        stdout: StdioCollector {
            id: activeCollector
            onStreamFinished: {
                root.toggled = activeCollector.text.trim() === "active"
            }
        }
    }

    Timer {
        // No D-Bus signal for wg-quick state, so poll occasionally in case the
        // tunnel was toggled outside the shell (e.g. from a terminal).
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkActiveProc.running = true
    }

    tooltipText: Translation.tr("WireGuard (home network)")
}
