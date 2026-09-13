-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Add your workspace rules here. Increment the workspace number as you go. Do not have duplicate workspaces.

local V = require("config.variables")

hl.workspace_rule({ workspace = "name:gaming", monitor = V.PRIMARY_MONITOR, default = true })
hl.workspace_rule({ workspace = "1", monitor = V.MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = V.MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = V.MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = V.MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "5", monitor = V.MONITOR1, default = true, persistent = true })
-- hl.workspace_rule({ workspace = "6", monitor = V.MONITOR2, default = true, persistent = true })

-- For other layouts such as scrolling, see example below
-- hl.workspace_rule({ workspace = "1", monitor = V.MONITOR1, default = true, persistent = true, layout = scroling })