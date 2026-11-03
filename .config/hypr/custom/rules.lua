-- Custom user rules for Hyprland
-- Frosted acrylic blur effect for Rofi menus
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0.5 })

-- Floating GUI Sliders (Volume, Brightness, Night Light)
hl.window_rule({ match = { class = "^(ii-slider)$" }, float = true })
hl.window_rule({ match = { class = "^(ii-slider)$" }, center = true })
hl.window_rule({ match = { class = "^(ii-slider)$" }, pin = true })
hl.window_rule({ match = { class = "^(ii-slider)$" }, stay_focused = true })
