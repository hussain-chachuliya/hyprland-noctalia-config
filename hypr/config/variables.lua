-- Hyprland shared values — single source of truth.
-- Consumed via: local V = require("config.variables")

local MONITOR1 = ""
local MONITOR2 = ""
local MONITOR3 = ""

local variables = {
    -- Default apps
    TERMINAL     = "alacritty",
    FILE_MANAGER = "thunar",
    BROWSER      = "firefox",
    EDITOR       = "mousepad",
    CALCULATOR   = "gnome-calculator",
    OPENCODE     = "opencode-desktop",

    -- Monitors
    MONITOR1 = MONITOR1,
    MONITOR2 = MONITOR2,
    MONITOR3 = MONITOR3,
    PRIMARY_MONITOR = MONITOR1,

    -- Workspaces
    NUM_WPM = 5, -- Number of workspaces per monitor (Max 10)

    -- Key bindings
    MOD_KEY       = "SUPER",
    NOCTALIA_CMD  = "noctalia msg ",
    LAUNCH_PREFIX = "uwsm app -- ", -- if you are not using UWSM, make this empty (e.g. "")
}

return variables