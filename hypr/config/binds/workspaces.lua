-- Workspace & monitor bindings
local V = require("config.variables")

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- Focus on monitors
hl.bind(V.MOD_KEY .. " + 1", hl.dsp.focus({ monitor = V.MONITOR1 }), { description = "Focus monitor 1" })
hl.bind(V.MOD_KEY .. " + 2", hl.dsp.focus({ monitor = V.MONITOR2 }), { description = "Focus monitor 2" })
hl.bind(V.MOD_KEY .. " + 3", hl.dsp.focus({ monitor = V.MONITOR3 }), { description = "Focus monitor 3" })

-- Focus on workspace number
-- Absolute
for i = 1, V.NUM_WPM do
    local key = i % 10
    hl.bind(V.MOD_KEY .. " + ALT + " .. key, hl.dsp.focus({ workspace = i }), { description = "Focus workspace " .. i })
end
-- Relative
for i = 1, V.NUM_WPM do
    local key = i % 10
    hl.bind(V.MOD_KEY .. " + SHIFT + " .. key, hl.dsp.focus({ workspace = "m~" .. i }), { description = "Focus workspace " .. i .. " (relative)" })
end

-- Move to adjacent workspaces and next empty on a given monitor
hl.bind(V.MOD_KEY .. " + CONTROL + Right",       hl.dsp.focus({ workspace = "m+1" }), { description = "Focus next workspace" })
hl.bind(V.MOD_KEY .. " + CONTROL + Left",        hl.dsp.focus({ workspace = "m-1" }), { description = "Focus previous workspace" })
hl.bind(V.MOD_KEY .. " + CONTROL + Down",        hl.dsp.focus({ workspace = "emptym" }), { description = "Focus next empty workspace" })

-- Scroll through existing workspaces & monitors
hl.bind(V.MOD_KEY .. " + mouse_down",           hl.dsp.focus({ workspace = "m-1" }), { description = "Focus previous workspace (scroll)" })
hl.bind(V.MOD_KEY .. " + mouse_up",             hl.dsp.focus({ workspace = "m+1" }), { description = "Focus next workspace (scroll)" })
hl.bind(V.MOD_KEY .. " + CONTROL + mouse_up",   hl.dsp.focus({ workspace = "m-1" }), { description = "Focus previous workspace (scroll)" })
hl.bind(V.MOD_KEY .. " + CONTROL + mouse_down", hl.dsp.focus({ workspace = "m+1" }), { description = "Focus next workspace (scroll)" })

-- Special workspace (scratchpad)
hl.bind(V.MOD_KEY .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }), { description = "Move window to scratchpad" })
hl.bind(V.MOD_KEY .. " + S",         hl.dsp.workspace.toggle_special(), { description = "Toggle scratchpad" })