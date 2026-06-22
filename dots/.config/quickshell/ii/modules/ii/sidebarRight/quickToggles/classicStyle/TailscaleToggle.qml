import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io

QuickToggleButton {
    id: root
    toggled: false
    buttonIcon: "lan"

    onClicked: {
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
                root.toggled = statusCollector.text.includes('"BackendState": "Running"')
            }
        }
    }

    StyledToolTip {
        text: Translation.tr("Tailscale")
    }
}
