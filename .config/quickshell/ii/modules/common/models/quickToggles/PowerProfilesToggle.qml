import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Power Profile")
    toggled: PowerProfiles.profile !== PowerProfile.Balanced
    icon: switch(PowerProfiles.profile) {
        case PowerProfile.PowerSaver: return "energy_savings_leaf"
        case PowerProfile.Balanced: return "airwave"
        case PowerProfile.Performance: return "local_fire_department"
    }
    statusText: switch(PowerProfiles.profile) {
        case PowerProfile.PowerSaver: return "Power Saver"
        case PowerProfile.Balanced: return "Balanced"
        case PowerProfile.Performance: return "Performance"
    }
    
    mainAction: () => {
        // Keep this tile focused on battery vs everyday use. The daemon may
        // advertise Performance even on a battery-focused laptop, which made
        // a click unexpectedly cycle through a third mode.
        PowerProfiles.profile = PowerProfiles.profile == PowerProfile.PowerSaver ? PowerProfile.Balanced : PowerProfile.PowerSaver
    }
    tooltipText: Translation.tr("Click to cycle through power profiles")
}
