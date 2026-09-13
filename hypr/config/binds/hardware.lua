-- Hardware control bindings
local V = require("config.variables")

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "volume-up"),   { locked = true, repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "volume-down"), { locked = true, repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "volume-mute"), { locked = true, description = "Toggle volume mute" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "mic-mute"),    { locked = true, description = "Toggle microphone mute" })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "media toggle"),   { locked = true, description = "Toggle media play/pause" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "media toggle"),   { locked = true, description = "Toggle media play/pause" })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "media next"),     { locked = true, description = "Next media track" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "media previous"), { locked = true, description = "Previous media track" })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "brightness-up"),   { locked = true, repeating = true, description = "Increase brightness" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "brightness-down"), { locked = true, repeating = true, description = "Decrease brightness" })