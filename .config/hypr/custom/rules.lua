-- Custom user rules for Hyprland
-- Frosted acrylic blur effect for Rofi menus
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0.5 })
