pragma Singleton

import qs.services
import qs.modules.common
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import Quickshell.Io

Singleton {
    id: root
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice?.percentage ?? 1
    readonly property bool allowAutomaticSuspend: Config.options.battery.automaticSuspend
    readonly property bool soundEnabled: Config.options.sounds.battery

    property bool isLow: available && (percentage <= Config.options.battery.low / 100)
    property bool isCritical: available && (percentage <= Config.options.battery.critical / 100)
    property bool isSuspending: available && (percentage <= Config.options.battery.suspend / 100)
    property bool isFull: available && (percentage >= Config.options.battery.full / 100)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isSuspendingAndNotCharging: allowAutomaticSuspend && isSuspending && !isCharging
    property bool isFullAndCharging: isFull && isCharging

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull

    property real health: (function() {
        const devList = UPower.devices.values;
        for (let i = 0; i < devList.length; ++i) {
            const dev = devList[i];
            if (dev.isLaptopBattery && dev.healthSupported) {
                const health = dev.healthPercentage;
                if (health === 0) {
                    return 0.01;
                } else if (health < 1) {
                    return health * 100;
                } else {
                    return health;
                }
            }
        }
        return 0;
    })()


    onIsLowAndNotChargingChanged: {
        if (!root.available || !isLowAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            Translation.tr("Low battery"), 
            Translation.tr("Consider plugging in your device"), 
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ])

        if (root.soundEnabled) Audio.playSystemSound("dialog-warning");
    }

    onIsCriticalAndNotChargingChanged: {
        if (!root.available || !isCriticalAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            Translation.tr("Critically low battery"), 
            Translation.tr("Please charge!\nAutomatic suspend triggers at %1%").arg(Config.options.battery.suspend), 
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);

        if (root.soundEnabled) Audio.playSystemSound("suspend-error");
    }

    onIsSuspendingAndNotChargingChanged: {
        if (root.available && isSuspendingAndNotCharging) {
            Quickshell.execDetached(["bash", "-c", `systemctl suspend || loginctl suspend`]);
        }
    }

    onIsFullAndChargingChanged: {
        if (!root.available || !isFullAndCharging) return;
        Quickshell.execDetached([
            "notify-send",
            Translation.tr("Battery full"),
            Translation.tr("Please unplug the charger"),
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);

        if (root.soundEnabled) Audio.playSystemSound("complete");
    }

    onIsPluggedInChanged: {
        if (!root.available || !root.soundEnabled) return;
        if (isPluggedIn) {
            Audio.playSystemSound("power-plug")
        } else {
            Audio.playSystemSound("power-unplug")
        }
    }

    // Charge limit — debounced write to sysfs + config file persistence
    // BAT1 hardcoded to match the battery-threshold-permissions systemd service
    property Timer chargeLimitTimer: Timer {
        interval: 400
        running: false
        onTriggered: {
            if (!Config.options.battery.chargeLimitEnabled) return;
            const limit = Config.options.battery.chargeLimit;
            const sysfs = "/sys/class/power_supply/BAT1/charge_control_end_threshold";
            const cfgFile = Quickshell.env("HOME") + "/.config/illogical-impulse/battery-charge-limit";
            Quickshell.execDetached(["bash", "-c",
                "echo " + limit + " > \"" + sysfs + "\" && printf '%d' " + limit + " > \"" + cfgFile + "\""
            ]);
        }
    }

    Connections {
        target: Config.options.battery
        function onChargeLimitChanged() { chargeLimitTimer.restart(); }
        function onChargeLimitEnabledChanged() { chargeLimitTimer.restart(); }
    }

    // Hypridle timeout rewrite — regenerates ~/.config/hypr/hypridle.conf and restarts hypridle
    property Timer hypridleTimer: Timer {
        interval: 800
        running: false
        onTriggered: {
            const home = Quickshell.env("HOME");
            const lock = Config.options.idle.lockTimeout * 60;
            const screen = Config.options.idle.screenOffTimeout * 60;
            const suspend = Config.options.idle.suspendTimeout * 60;
            const lockMin = Config.options.idle.lockTimeout;
            const screenMin = Config.options.idle.screenOffTimeout;
            const suspendMin = Config.options.idle.suspendTimeout;

            // Build conf without shell variable references to keep escaping simple
            const lockCmd = "hyprctl dispatch 'hl.dsp.global(\"quickshell:lock\")' & pidof qs quickshell hyprlock || hyprlock";
            const suspendCmd = "systemctl suspend || loginctl suspend";

            let conf = "# Generated by QuickShell Power settings\n"
                + "general {\n"
                + "    lock_cmd = " + lockCmd + "\n"
                + "    before_sleep_cmd = loginctl lock-session\n"
                + "    after_sleep_cmd = hyprctl dispatch 'hl.dsp.global(\"quickshell:lockFocus\")'\n"
                + "    inhibit_sleep = 3\n"
                + "}\n\n"
                + "listener {\n"
                + "    timeout = " + lock + " # " + lockMin + " mins\n"
                + "    on-timeout = loginctl lock-session\n"
                + "}\n\n"
                + "listener {\n"
                + "    timeout = " + screen + " # " + screenMin + " mins\n"
                + "    on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'\n"
                + "    on-resume = hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'\n"
                + "}\n";

            if (suspend > 0) {
                conf += "\nlistener {\n"
                    + "    timeout = " + suspend + " # " + suspendMin + " mins\n"
                    + "    on-timeout = " + suspendCmd + "\n"
                    + "}\n";
            }

            // Use base64 to safely pass the conf content through bash without escaping issues
            const confPath = home + "/.config/hypr/hypridle.conf";
            const confB64 = Qt.btoa(conf);
            Quickshell.execDetached(["bash", "-c",
                "echo '" + confB64 + "' | base64 -d > \"" + confPath + "\" && pkill hypridle; hypridle &"
            ]);
        }
    }

    Connections {
        target: Config.options.idle
        function onLockTimeoutChanged() { hypridleTimer.restart(); }
        function onScreenOffTimeoutChanged() { hypridleTimer.restart(); }
        function onSuspendTimeoutChanged() { hypridleTimer.restart(); }
    }

    // Apply Hyprland perf optimizations when power profile changes (wiki.hypr.land/…/Performance/).
    // resetMany restores whatever the user had configured; setMany overrides only while in Power Saver.
    Connections {
        target: PowerProfiles
        function onProfileChanged() {
            if (PowerProfiles.profile === PowerProfile.PowerSaver) {
                HyprlandConfig.setMany({
                    "decoration:blur:enabled": 0,
                    "decoration:shadow:enabled": 0,
                    "animations:enabled": 0,
                });
            } else {
                HyprlandConfig.resetMany([
                    "decoration:blur:enabled",
                    "decoration:shadow:enabled",
                    "animations:enabled",
                ]);
            }
        }
    }
}
