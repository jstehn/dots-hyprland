import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("Tailscale")

    available: false
    toggled: false
    icon: "lan"

    mainAction: () => {
        if (toggled) {
            root.toggled = false
            Quickshell.execDetached(["tailscale", "down"])
        } else {
            root.toggled = true
            upProc.running = true
        }
    }

    Process {
        id: upProc
        command: ["tailscale", "up"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.toggled = false
                Quickshell.execDetached(["notify-send",
                    Translation.tr("Tailscale"),
                    Translation.tr("Connection failed. Please inspect manually with the <tt>tailscale</tt> command"),
                    "-a", "Shell"
                ])
            }
        }
    }

    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", "tailscale status --json"]
        stdout: StdioCollector {
            id: statusCollector
            onStreamFinished: {
                if (statusCollector.text.length > 0) {
                    root.available = true
                }
                root.toggled = statusCollector.text.includes('"BackendState": "Running"')
            }
        }
    }

    Timer {
        // No D-Bus signal for tailscaled state, so poll occasionally in case
        // it was toggled outside the shell (e.g. from a terminal).
        interval: 5000
        running: root.available
        repeat: true
        onTriggered: fetchActiveState.running = true
    }

    tooltipText: Translation.tr("Tailscale")
}
