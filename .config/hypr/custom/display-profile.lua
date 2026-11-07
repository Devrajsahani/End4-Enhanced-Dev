-- Persist monitor choices across Hyprland config reloads and monitor hotplug.
local INTERNAL = "eDP-1"
local EXTERNAL = "HDMI-A-1"
local PROFILE_FILE = (os.getenv("HOME") or "") .. "/.config/hypr/display-profile"
local PREFERRED_FILE = (os.getenv("HOME") or "") .. "/.config/hypr/preferred-external-profile"
local LAPTOP_MODE = "1920x1080@144.0"
local EXTERNAL_MODE = "1920x1080@119.88"

local function readProfile()
    local file = io.open(PROFILE_FILE, "r")
    if not file then return "laptop-only" end
    local profile = file:read("*l") or "laptop-only"
    file:close()
    profile = profile:gsub("%s+", "")
    if profile == "external-only" or profile == "extend" or profile == "laptop-only" then
        return profile
    end
    return "laptop-only"
end

local function writeProfile(profile)
    local file = io.open(PROFILE_FILE, "w")
    if file then
        file:write(profile .. "\n")
        file:close()
    end
end

local function readPreferredProfile()
    local file = io.open(PREFERRED_FILE, "r")
    if not file then return "extend" end
    local profile = file:read("*l") or "extend"
    file:close()
    profile = profile:gsub("%s+", "")
    if profile == "external-only" or profile == "extend" or profile == "laptop-only" then
        return profile
    end
    return "extend"
end

local function writePreferredProfile(profile)
    local file = io.open(PREFERRED_FILE, "w")
    if file then
        file:write(profile .. "\n")
        file:close()
    end
end

local function isConnected(output)
    local pipe = io.popen("for f in /sys/class/drm/card*-" .. output .. "/status; do [ -r \"$f\" ] && cat \"$f\"; done 2>/dev/null")
    if not pipe then return false end
    local status = pipe:read("*a") or ""
    pipe:close()
    for line in status:gmatch("[^\r\n]+") do
        local trimmed = line:gsub("^%s*(.-)%s*$", "%1")
        if trimmed == "connected" then
            return true
        end
    end
    return false
end

function applyDisplayProfile(targetProfile)
    local externalConnected = isConnected(EXTERNAL)
    local profile = targetProfile or readProfile()

    if not externalConnected then
        -- Default to laptop screen whenever HDMI cable is not connected
        profile = "laptop-only"
        writeProfile("laptop-only")
        hl.monitor({ output = EXTERNAL, disabled = true })
        hl.monitor({ output = INTERNAL, disabled = false, mode = LAPTOP_MODE, position = "0x0", scale = 1 })
        hl.dispatch(hl.dsp.focus({ monitor = INTERNAL }))
        return
    end

    -- HDMI is connected
    if profile == "external-only" then
        writePreferredProfile("external-only")
        writeProfile("external-only")
        hl.monitor({ output = INTERNAL, disabled = true })
        hl.monitor({ output = EXTERNAL, disabled = false, mode = EXTERNAL_MODE, position = "0x0", scale = 1 })
        hl.dispatch(hl.dsp.focus({ monitor = EXTERNAL }))
    elseif profile == "extend" then
        writePreferredProfile("extend")
        writeProfile("extend")
        hl.monitor({ output = INTERNAL, disabled = false, mode = LAPTOP_MODE, position = "0x0", scale = 1 })
        hl.monitor({ output = EXTERNAL, disabled = false, mode = EXTERNAL_MODE, position = "1920x0", scale = 1 })
        hl.dispatch(hl.dsp.focus({ monitor = INTERNAL }))
    else -- "laptop-only"
        writeProfile("laptop-only")
        hl.monitor({ output = EXTERNAL, disabled = true })
        hl.monitor({ output = INTERNAL, disabled = false, mode = LAPTOP_MODE, position = "0x0", scale = 1 })
        hl.dispatch(hl.dsp.focus({ monitor = INTERNAL }))
    end
end

-- Reapply on startup / config reload
applyDisplayProfile()

-- Monitor hotplug handlers
hl.on("monitor.added", function()
    if isConnected(EXTERNAL) then
        local pref = readPreferredProfile()
        applyDisplayProfile(pref)
        local desc = (pref == "external-only") and "External Monitor Only (Acer 120Hz)" or "Extended Dual Displays"
        os.execute("notify-send -a 'Display Manager' -i 'video-display' 'HDMI Connected' 'Applied " .. desc .. ".' &")
    end
end)

hl.on("monitor.removed", function()
    if not isConnected(EXTERNAL) then
        applyDisplayProfile("laptop-only")
        os.execute("notify-send -a 'Display Manager' -i 'video-display' 'HDMI Disconnected' 'Defaulted to Laptop Screen (1080p@144Hz).' &")
    end
end)
