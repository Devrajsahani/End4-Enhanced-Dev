-- User custom keybindings for Hyprland & QuickShell Rice
-- Config editing & Display profiles
hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "System: Edit user keybinds"})
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/display-switch.sh"), {description = "Display: Choose monitor profile"})
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/display-switch.sh"), {description = "Display: Choose monitor profile"})

-- Rofi Appearance Pickers (Modernized Grids & Cards)
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-bar-layout"), {description = "Appearance: Choose top bar layout"})
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-theme wallpaper"), {description = "Appearance: Choose wallpaper"})
hl.bind("SUPER + ALT + T", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-theme theme"), {description = "Appearance: Choose theme pack"})

-- Productivity & System Switchers
hl.bind("SUPER + Slash", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-keybinds"), {description = "Help: Search keybindings & cheatsheet"})
hl.bind("SUPER + F1", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-keybinds"), {description = "Help: Search keybindings & cheatsheet"})
hl.bind("SUPER + ALT + K", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-keybinds"), {description = "Help: Search keybindings & cheatsheet"})
hl.bind("SUPER + ALT + A", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-anim"), {description = "Appearance: Switch animation profile"})
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control"), {description = "System: Quick Controls & Productivity Hub"})
hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-slider all"), {description = "Media: Floating GUI Sliders Hub (Volume/Brightness/Nightlight)"})
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-slider volume"), {description = "Media: Floating Volume Slider"})
hl.bind("SUPER + ALT + N", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-slider nightlight"), {description = "Display: Floating Night Light Slider"})
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-audio"), {description = "Media: Switch audio output or microphone"})

-- Volume & Brightness Direct Controls (Keyboard & Hardware)
hl.bind("SUPER + ALT + Up", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control vol-up 5"), {description = "Volume: Increase (+5%)", repeating = true})
hl.bind("SUPER + ALT + Down", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control vol-down 5"), {description = "Volume: Decrease (-5%)", repeating = true})
hl.bind("SUPER + ALT + Right", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control bright-up 5"), {description = "Brightness: Increase (+5%)", repeating = true})
hl.bind("SUPER + ALT + Left", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control bright-down 5"), {description = "Brightness: Decrease (-5%)", repeating = true})
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control mute"), {description = "Volume: Toggle mute"})

-- Precise Hardware Media & Backlight Keys (Step 1% with ALT, 5% standard)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control vol-up 5"), {description = "Volume: Hardware raise (+5%)", locked = true, repeating = true})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control vol-down 5"), {description = "Volume: Hardware lower (-5%)", locked = true, repeating = true})
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control vol-up 1"), {description = "Volume: Precise raise (+1%)", locked = true, repeating = true})
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control vol-down 1"), {description = "Volume: Precise lower (-1%)", locked = true, repeating = true})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control mute"), {description = "Volume: Hardware mute toggle", locked = true})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control bright-up 5"), {description = "Brightness: Hardware raise (+5%)", locked = true, repeating = true})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control bright-down 5"), {description = "Brightness: Hardware lower (-5%)", locked = true, repeating = true})
hl.bind("ALT + XF86MonBrightnessUp", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control bright-up 1"), {description = "Brightness: Precise raise (+1%)", locked = true, repeating = true})
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd(HOME .. "/.local/bin/ii-control bright-down 1"), {description = "Brightness: Precise lower (-1%)", locked = true, repeating = true})
