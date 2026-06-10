import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "battery_charging_50"
        title: Translation.tr("Charge Limit")

        ConfigRow {
            uniform: false
            Layout.fillWidth: false
            ConfigSwitch {
                buttonIcon: "battery_charging_50"
                text: Translation.tr("Limit charging")
                checked: Config.options.battery.chargeLimitEnabled
                onCheckedChanged: {
                    Config.options.battery.chargeLimitEnabled = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Limits the maximum battery charge percentage")
                }
            }
            ConfigSpinBox {
                enabled: Config.options.battery.chargeLimitEnabled
                icon: "battery_5_bar"
                text: Translation.tr("Charge limit (%)")
                value: Config.options.battery.chargeLimit
                from: 50
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.chargeLimit = value;
                }
            }
        }
    }

    ContentSection {
        icon: "bedtime"
        title: Translation.tr("Idle & Sleep")

        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "lock"
                text: Translation.tr("Lock screen after (min)")
                value: Config.options.idle.lockTimeout
                from: 1
                to: 60
                stepSize: 1
                onValueChanged: {
                    Config.options.idle.lockTimeout = value;
                }
            }
            ConfigSpinBox {
                icon: "monitor_off"
                text: Translation.tr("Screen off after (min)")
                value: Config.options.idle.screenOffTimeout
                from: 1
                to: 120
                stepSize: 1
                onValueChanged: {
                    Config.options.idle.screenOffTimeout = value;
                }
            }
        }
        ConfigRow {
            uniform: false
            Layout.fillWidth: false
            ConfigSpinBox {
                icon: "bedtime"
                text: Translation.tr("Suspend after (min, 0 = never)")
                value: Config.options.idle.suspendTimeout
                from: 0
                to: 240
                stepSize: 5
                onValueChanged: {
                    Config.options.idle.suspendTimeout = value;
                }
            }
        }
    }
}
