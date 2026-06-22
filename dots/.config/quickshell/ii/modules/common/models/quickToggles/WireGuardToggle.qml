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

    // Hidden by default until checkUnitProc confirms the unit exists, since
    // this config is shared across hosts that don't all define wg-quick.
    available: false
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
        id: checkUnitProc
        running: true
        command: ["systemctl", "list-unit-files", "--no-legend", root.unit]
        onExited: (exitCode, exitStatus) => {
            root.available = exitCode === 0
        }
    }

    Process {
        id: checkActiveProc
        running: root.available
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
        running: root.available
        repeat: true
        onTriggered: checkActiveProc.running = true
    }

    tooltipText: Translation.tr("WireGuard (home network)")
}
