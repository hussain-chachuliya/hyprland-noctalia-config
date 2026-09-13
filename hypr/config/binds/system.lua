-- System & hardware bindings
local V = require("config.variables")

----------------------------
---- SYSTEM & HARDWARE -----
----------------------------

-- System config
hl.bind(V.MOD_KEY .. " + CTRL + R",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "config-reload"), { description = "Reload Noctalia config" })
hl.bind(V.MOD_KEY .. " + SHIFT + R",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "config-reload"), { description = "Reload Noctalia config" })

-- Bar
hl.bind(V.MOD_KEY .. " + CTRL + B",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "bar-toggle"), { description = "Toggle top bar" })
hl.bind(V.MOD_KEY .. " + ALT + B",    hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "bar-auto-hide-set toggle"), { description = "Toggle bar auto-hide" })

-- Dock
hl.bind(V.MOD_KEY .. " + SHIFT + D",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "dock-reload"), { description = "Reload dock" })
hl.bind(V.MOD_KEY .. " + CTRL + D",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "dock-toggle"), { description = "Toggle dock" })
hl.bind(V.MOD_KEY .. " + ALT + D",    hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "dock-auto-hide-set toggle"), { description = "Toggle dock auto-hide" })

-- Toggles
hl.bind(V.MOD_KEY .. " + CTRL + G",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "caffeine-toggle"), { description = "Toggle caffeine (keep awake)" })
hl.bind(V.MOD_KEY .. " + CTRL + U",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "nightlight-toggle"), { description = "Toggle night light" })
hl.bind(V.MOD_KEY .. " + CTRL + O",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "osd-toggle"), { description = "Toggle on-screen display" })
hl.bind(V.MOD_KEY .. " + SHIFT + G",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "bluetooth-toggle"), { description = "Toggle Bluetooth" })
hl.bind(V.MOD_KEY .. " + CTRL + F",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "wifi-toggle"), { description = "Toggle Wi-Fi" })
hl.bind(V.MOD_KEY .. " + CTRL + X",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "network-toggle"), { description = "Toggle network" })

-- Display power
hl.bind(V.MOD_KEY .. " + F11",        hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "dpms-on"), { description = "Turn displays on" })
hl.bind(V.MOD_KEY .. " + F12",        hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "dpms-off"), { description = "Turn displays off" })