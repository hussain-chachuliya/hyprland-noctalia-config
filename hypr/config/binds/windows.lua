-- Window bindings
local V = require("config.variables")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
hl.bind(V.MOD_KEY .. " + Escape",      hl.dsp.exec_cmd("hyprctl kill"),          { description = "Kill active window" })
hl.bind(V.MOD_KEY .. " + Q",           hl.dsp.window.close(),                    { description = "Close active window" })
hl.bind(V.MOD_KEY .. " + SHIFT + Q",   hl.dsp.exec_cmd("hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"), { description = "Force-close active window process" })
hl.bind(V.MOD_KEY .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating mode" })
hl.bind(V.MOD_KEY .. " + F",           hl.dsp.window.fullscreen(),                { description = "Toggle fullscreen client" })
hl.bind(V.MOD_KEY .. " + M",           hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize window" })
hl.bind(V.MOD_KEY .. " + G",           hl.dsp.group.toggle(),                     { description = "Toggle window group" })

-- Change focus
hl.bind(V.MOD_KEY .. " + Left",  hl.dsp.focus({ direction = "left" }),  { description = "Focus window left" })
hl.bind(V.MOD_KEY .. " + Right", hl.dsp.focus({ direction = "right" }), { description = "Focus window right" })
hl.bind(V.MOD_KEY .. " + Up",    hl.dsp.focus({ direction = "up" }),    { description = "Focus window up" })
hl.bind(V.MOD_KEY .. " + Down",  hl.dsp.focus({ direction = "down" }),  { description = "Focus window down" })
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next(),            { description = "Cycle to next window" })
hl.bind(V.MOD_KEY .. " + Tab",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "window-switcher"), { description = "Open window switcher" })

-- Swap windows in direction
hl.bind(V.MOD_KEY .. " + ALT + Left",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
hl.bind(V.MOD_KEY .. " + ALT + Right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })
hl.bind(V.MOD_KEY .. " + ALT + Up",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind(V.MOD_KEY .. " + ALT + Down",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

-- Move active window around workspaces & monitors
hl.bind(V.MOD_KEY .. " + ALT + SHIFT + 1",              hl.dsp.window.move({ monitor = V.MONITOR1 }), { description = "Move window to monitor 1" })
hl.bind(V.MOD_KEY .. " + ALT + SHIFT + 2",              hl.dsp.window.move({ monitor = V.MONITOR2 }), { description = "Move window to monitor 2" })
hl.bind(V.MOD_KEY .. " + ALT + SHIFT + 3",              hl.dsp.window.move({ monitor = V.MONITOR3 }), { description = "Move window to monitor 3" })
hl.bind(V.MOD_KEY .. " + SHIFT + mouse_up",             hl.dsp.window.move({ monitor   = "-1" }), { description = "Move window to next monitor" })
hl.bind(V.MOD_KEY .. " + SHIFT + mouse_down",           hl.dsp.window.move({ monitor   = "+1" }), { description = "Move window to previous monitor" })
hl.bind(V.MOD_KEY .. " + CONTROL + SHIFT + Right",      hl.dsp.window.move({ workspace = "m+1" }), { description = "Move window to next workspace" })
hl.bind(V.MOD_KEY .. " + CONTROL + SHIFT + Left",       hl.dsp.window.move({ workspace = "m-1" }), { description = "Move window to previous workspace" })
hl.bind(V.MOD_KEY .. " + CONTROL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }), { description = "Move window to previous workspace" })
hl.bind(V.MOD_KEY .. " + CONTROL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "m+1" }), { description = "Move window to next workspace" })
for i = 1, V.NUM_WPM do
    local key = i % 10
    hl.bind(V.MOD_KEY .. " + SHIFT + CONTROL + " .. key, hl.dsp.window.move({ workspace = "m~" .. i }), { description = "Move window to workspace " .. i })
end

-- Move & Resize with mouse
hl.bind(V.MOD_KEY .. " + mouse:272", hl.dsp.window.drag(),        { description = "Drag floating window" })
hl.bind(V.MOD_KEY .. " + mouse:273", hl.dsp.window.resize(),      { description = "Resize floating window" })

-- Zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind(V.MOD_KEY .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Zoom out" })
hl.bind(V.MOD_KEY .. " + Plus", function() zoomfunction(0.3) end, { repeating = true, description = "Zoom in" })

--# Zoom with keypad
hl.bind(V.MOD_KEY .. " + code:82", function() zoomfunction(-0.3) end, { repeating = true, description = "Zoom out (keypad)" })
hl.bind(V.MOD_KEY .. " + code:86", function() zoomfunction(0.3) end, { repeating = true, description = "Zoom in (keypad)" })