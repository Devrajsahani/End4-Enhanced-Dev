# Theme and top bar behavior

The theme and wallpaper pickers use Illogical Impulse's existing `switchwall.sh` and Matugen pipeline. The wallpaper path is written to the current configuration first; Quickshell watches that config file and crossfades between the previous and incoming image. Matugen's generated palette is also watched directly by Quickshell, so theme changes no longer trigger a delayed shell reload.

`Super+Alt+B` opens the Rofi top bar picker. The choices are:

- **Pill Islands:** Arch and workspaces at the left, clock in the center, and independent controls on the right.
- **Left Dock:** Arch, workspaces, and clock form a left dock; the right-side toggles share one larger capsule.
- **Centered Capsule:** Arch remains at the left, workspaces move into the centered clock capsule, and controls stay at the right.

The active choice is stored in Quickshell's persistent state and updates live through its IPC handler. Bar capsules animate their palette and outline when Matugen changes the active theme. Wallpaper transitions use an 850 ms eased crossfade. This adapts the smooth crossfade idea while keeping the current Illogical Impulse wallpaper and Quickshell setup; it does not install or launch awww.

The layouts keep Illogical Impulse's existing panel family, monitor list, bar anchors, workspace behavior, and network/Bluetooth/power controls. They do not call `hyprctl reload` or change monitor modes.
