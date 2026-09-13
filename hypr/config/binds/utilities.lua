-- Utility bindings
local V = require("config.variables")

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
hl.bind("Print",                   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-fullscreen"), { description = "Capture region" })
hl.bind(V.MOD_KEY .. " + Print",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-region"), { description = "Capture fullscreen" })
hl.bind(V.MOD_KEY .. " + ALT + F", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-fullscreen"), { description = "Capture fullscreen" })
hl.bind(V.MOD_KEY .. " + ALT + S", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-region"), { description = "Capture region" })

-- Theming and Wallpaper
hl.bind(V.MOD_KEY .. " + P",         hl.dsp.exec_cmd("hyprpicker -a -n"),       { description = "Pick color" })
hl.bind(V.MOD_KEY .. " + SHIFT + W", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle wallpaper"), { description = "Open wallpaper picker" })
hl.bind(V.MOD_KEY .. " + CTRL + W",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "wallpaper-random"), { description = "Set random wallpaper" })
hl.bind(V.MOD_KEY .. " + SHIFT + M", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "theme-mode-toggle"), { description = "Toggle dark/light theme" })

-- Clipboard
hl.bind(V.MOD_KEY .. " + V", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle clipboard"), { description = "Open clipboard history" })

-- Notifications
hl.bind(V.MOD_KEY .. " + A",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle control-center notifications"), { description = "Open notifications center" })
hl.bind(V.MOD_KEY .. " + CTRL + N",    hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "notification-dnd-toggle"), { description = "Toggle do-not-disturb" })
hl.bind(V.MOD_KEY .. " + SHIFT + N",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "notification-clear-active"), { description = "Clear active notifications" })