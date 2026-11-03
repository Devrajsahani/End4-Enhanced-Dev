-- Custom general configurations
-- Dynamically load active animation preset if available
local active_anim = os.getenv("HOME") .. "/.config/hypr/custom/animations/active.lua"
local f = io.open(active_anim, "r")
if f then
    f:close()
    dofile(active_anim)
end
