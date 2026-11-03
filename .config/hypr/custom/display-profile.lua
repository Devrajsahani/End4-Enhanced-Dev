-- Persist monitor choices across Hyprland config reloads and monitor hotplug.
local INTERNAL = "eDP-1"
local EXTERNAL = "HDMI-A-1"
local PROFILE_FILE = (os.getenv("HOME") or "") .. "/.config/hypr/display-profile"
local LAPTOP_MODE = "1920x1080@60"
local EXTERNAL_MODE = "1920x1080@119.88"

local function readProfile()
    local file = io.open(PROFILE_FILE, "r")
    if not file then return "laptop-only" end
    local profile = file:read("*l") or "laptop-only"
    file:close()
    if profile == "external-only" or profile == "extend" or profile == "laptop-only" then
        return profile
    end
    return "laptop-only"
end

local function isConnected(output)
    local pipe = io.popen("for f in /sys/class/drm/card*-" .. output .. "/status; do [ -r \"$f\" ] && cat \"$f\"; done 2>/dev/null")
    if not pipe then return false end
    local status = pipe:read("*a") or ""
    pipe:close()
    return status:find("connected", 1, true) ~= nil
end

function applyDisplayProfile()
    local profile = readProfile()
    local externalConnected = isConnected(EXTERNAL)

    if profile == "external-only" and externalConnected then
        hl.monitor({ output = INTERNAL, disabled = true })
        hl.monitor({ output = EXTERNAL, disabled = false, mode = EXTERNAL_MODE, position = "0x0", scale = 1 })
    elseif profile == "extend" and externalConnected then
        hl.monitor({ output = INTERNAL, disabled = false, mode = LAPTOP_MODE, position = "0x0", scale = 1 })
        hl.monitor({ output = EXTERNAL, disabled = false, mode = EXTERNAL_MODE, position = "1920x0", scale = 1 })
    else
        -- Keep a usable laptop display if the external monitor is unplugged.
        hl.monitor({ output = EXTERNAL, disabled = true })
        hl.monitor({ output = INTERNAL, disabled = false, mode = LAPTOP_MODE, position = "0x0", scale = 1 })
    end
end

-- Reapply after config reloads so the generated laptop-only rule cannot undo
-- an explicitly selected external-only or extended profile.
applyDisplayProfile()

-- If a monitor is plugged or unplugged, restore the saved profile. The
-- connection check falls back to the laptop panel if HDMI is unavailable.
hl.on("monitor.added", function() applyDisplayProfile() end)
hl.on("monitor.removed", function() applyDisplayProfile() end)
