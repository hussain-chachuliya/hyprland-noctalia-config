-- CachyOS Hyprland Configuration
--
-- Layering (later layer wins where it sets a key):
--   Layer 1: hand-edited base config in config/
--   Layer 2: HyprMod GUI overrides (hyprland-gui.lua, tool-generated)
--   Layer 3: Noctalia live theme (noctalia.lua, tool-generated)
--
-- Modules self-require their deps ("config.variables" / "config.colors"),
-- so require order within Layer 1 is cosmetic.

---- Layer 1: Base config (hand-edited) ----
require("config.animations")
require("config.environment")
require("config.inputs")
require("config.autostart")
require("config.colors")
require("config.variables")
require("config.decorations")
require("config.misc")
require("config.monitors")
require("config.workspaces")
require("config.binds.windows")
require("config.binds.launcher")
require("config.binds.hardware")
require("config.binds.utilities")
require("config.binds.workspaces")
require("config.binds.system")
require("config.windowrules.global")
require("config.windowrules.apps")
require("config.windowrules.gaming")
require("config.windowrules.floats")

---- Layer 2: Tool-managed (HyprMod GUI) — overrides Layer 1 ----
require("hyprland-gui")

---- Layer 3: Live theme (Noctalia) — overrides Layers 1-2 ----
require("noctalia").apply_theme()

