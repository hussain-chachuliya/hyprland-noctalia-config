-- Launcher bindings
local V = require("config.variables")

------------------
---- LAUNCHER ----
------------------

hl.bind(V.MOD_KEY .. " + Return",      hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.TERMINAL),     { description = "Open terminal" })
hl.bind(V.MOD_KEY .. " + E",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.FILE_MANAGER), { description = "Open file manager" })
hl.bind(V.MOD_KEY .. " + T",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.EDITOR),       { description = "Open text editor" })
hl.bind("XF86Calculator",              hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.CALCULATOR),   { description = "Open calculator" })
hl.bind(V.MOD_KEY .. " + B",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.BROWSER),      { description = "Open browser" })
hl.bind(V.MOD_KEY .. " + O",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.OPENCODE),     { description = "Open OpenCode" })
hl.bind(V.MOD_KEY .. " + N",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.NOTES),        { description = "Open obsidian" })
hl.bind("CONTROL + ALT + Delete",      hl.dsp.exec_cmd("missioncenter"),                   { description = "Open Mission Center" })
hl.bind(V.MOD_KEY .. " + Z",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "settings-toggle"),            { description = "Toggle settings panel" })
hl.bind(V.MOD_KEY .. " + Space",       hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle launcher"),      { description = "Open launcher" })
hl.bind(V.MOD_KEY .. " + period",      hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle launcher /emo"), { description = "Open emoji picker" })
hl.bind(V.MOD_KEY .. " + L",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "session lock"),               { description = "Lock session" })
