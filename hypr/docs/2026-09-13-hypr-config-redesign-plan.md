# Hyprland Config Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Hyprland Lua config self-documenting and order-independent by converting bare-global shared values to require/return tables, splitting windowrules by category, and making the tool-generated override chain explicit.

**Architecture:** `config/variables.lua` and `config/colors.lua` return tables; every consumer declares `local V = require("config.variables")` / `local C = require("config.colors")`. `windowrules.lua` splits into four category modules. `hyprland.lua` becomes a three-layer documented manifest.

**Tech Stack:** Lua 5.x (hyprland.lua / hspr runtime), `hl.*` config API, `hyprctl` CLI for verification, `luac` for syntax checks.

**Spec:** `~/.config/hypr/docs/2026-09-13-hypr-config-redesign.md`

## Global Constraints

- **No git repo exists** — the plan's per-task "Commit" steps are replaced by a syntax/consistency checkpoint. Do not run any git commands.
- **Preserve behavior exactly.** No key/value renames. Escape sequences inside string literals (e.g. `"^(steam)$"`, `initial_title = "negative:^(.*\\\\home\\\\.*)$"`) must be copied character-for-character from the originals.
- **Do not edit** `hyprland-gui.lua`, `noctalia.lua`, or `xdph.conf`.
- The `hl` global only exists at runtime; modules cannot be `require`d standalone for testing. Verification for every file change is `luac -p <file>` (syntax) plus the grep consistency checks listed per task. Full runtime verification happens in Task 4.
- Later-layer-wins override contract: Layer 1 = `config/*` (hand-edited), Layer 2 = `hyprland-gui.lua`, Layer 3 = `noctalia.apply_theme()`.

---

### Task 1: `colors.lua` → return table; update consumers `decorations.lua`, `misc.lua`

**Files:**
- Rewrite: `~/.config/hypr/config/colors.lua`
- Modify: `~/.config/hypr/config/decorations.lua`
- Modify: `~/.config/hypr/config/misc.lua`

**Interfaces:**
- Produces: `require("config.colors")` returns table with keys `CACHYLGREEN, CACHYMGREEN, CACHYDGREEN, CACHYLBLUE, CACHYMBLUE, CACHYDBLUE, CACHYWHITE, CACHYGREY, CACHYGRAY`.

- [ ] **Step 1: Rewrite `config/colors.lua` — delete the global-assignment file and write:**

```lua
-- Cachy colors — shared palette.
-- Consumed via: local C = require("config.colors")

return {
    CACHYLGREEN = "rgba(82dcccff)",
    CACHYMGREEN = "rgba(00aa84ff)",
    CACHYDGREEN = "rgba(007d6fff)",
    CACHYLBLUE  = "rgba(01ccffff)",
    CACHYMBLUE  = "rgba(182545ff)",
    CACHYDBLUE  = "rgba(111826ff)",
    CACHYWHITE  = "rgba(ffffffff)",
    CACHYGREY   = "rgba(ddddddff)",
    CACHYGRAY   = "rgba(798bb2ff)",
}
```

- [ ] **Step 2: Update `config/decorations.lua`**

Prepend the require line after the existing `-- Look and feel configuration` comment:

```lua
local C = require("config.colors")
```

Then rewrite the body so every bare color reference is prefixed `C.`. The full resulting file:

```lua
-- Look and feel configuration

local C = require("config.colors")

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 40,
        resize_on_border = true,
        col = {
            active_border = {
                colors = { C.CACHYLGREEN, C.CACHYDGREEN },
                angle = 45,
            },
            inactive_border = C.CACHYGRAY,
        },
    },
    group = {
        col = {
            border_active = C.CACHYLBLUE,
            border_inactive = C.CACHYGRAY,
            border_locked_active = C.CACHYDBLUE,
            border_locked_inactive = C.CACHYGRAY,
        },
        groupbar = {
            col = {
                active = C.CACHYLGREEN,
                inactive = C.CACHYGRAY,
                locked_active = C.CACHYDBLUE,
                locked_inactive = C.CACHYGRAY,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 10,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        fullscreen_opacity = 1,
        blur = {
            size = 5,
            passes = 4,
            special = true,
        },
    },
})
```

- [ ] **Step 3: Update `config/misc.lua`**

Prepend the require after the file's existing comment:

```lua
local C = require("config.colors")
```

and change `splash = CACHYLGREEN,` to `splash = C.CACHYLGREEN,`. Full resulting file:

```lua
local C = require("config.colors")

hl.config({
    dwindle = {
        preserve_split = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
    misc = {
        col = {
            splash = C.CACHYLGREEN,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        vrr = 3,
    },
    render = {
        direct_scanout = 2,
    },
    xwayland = {
        force_zero_scaling = true
    },
})
```

- [ ] **Step 4: Verify Task 1**

Run:
```bash
luac -p ~/.config/hypr/config/colors.lua ~/.config/hypr/config/decorations.lua ~/.config/hypr/config/misc.lua && echo syntax-OK
```
Expected: `syntax-OK`.

Run:
```bash
rg -n '^\s*CACHY' ~/.config/hypr/config
```
Expected: **no matches** outside `config/colors.lua` except none at all (colors.lua now uses `CACHYLGREEN = ...` inside the returned table, unindented — the regex `^\s*CACHY` will still match the table keys in colors.lua, so expect matches *only* in `config/colors.lua:4-12`). Verify none appear in `decorations.lua`/`misc.lua`.

**Checkpoint reached (no git commit; repo has no git).**

---

### Task 2: `variables.lua` → return table; update all consumers

**Files:**
- Rewrite: `~/.config/hypr/config/variables.lua`
- Modify: `~/.config/hypr/config/monitors.lua`
- Modify: `~/.config/hypr/config/workspaces.lua`
- Modify: `~/.config/hypr/config/binds/windows.lua`
- Modify: `~/.config/hypr/config/binds/launcher.lua`
- Modify: `~/.config/hypr/config/binds/hardware.lua`
- Modify: `~/.config/hypr/config/binds/utilities.lua`
- Modify: `~/.config/hypr/config/binds/workspaces.lua`
- Modify: `~/.config/hypr/config/binds/system.lua`

**Interfaces:**
- Produces: `require("config.variables")` returns table with keys `TERMINAL, FILE_MANAGER, BROWSER, EDITOR, CALCULATOR, OPENCODE, MONITOR1, MONITOR2, MONITOR3, PRIMARY_MONITOR, NUM_WPM, MOD_KEY, NOCTALIA_CMD, LAUNCH_PREFIX`.

- [ ] **Step 1: Rewrite `config/variables.lua`**

Note: `PRIMARY_MONITOR` must track `MONITOR1` (the original file set `PRIMARY_MONITOR = MONITOR1`). Using file-locals preserves that alias semantics when only `MONITOR1` is edited. Full file:

```lua
-- Hyprland shared values — single source of truth.
-- Consumed via: local V = require("config.variables")

local MONITOR1 = ""
local MONITOR2 = ""
local MONITOR3 = ""

local variables = {
    -- Default apps
    TERMINAL     = "alacritty",
    FILE_MANAGER = "thunar",
    BROWSER      = "brave",
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
```

- [ ] **Step 2: Update `config/monitors.lua`**

Prepend `local V = require("config.variables")` and replace `output = MONITOR1` with `output = V.MONITOR1`. Full resulting file:

```lua
-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = "MONITOR1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

local V = require("config.variables")

hl.monitor({
    output    = V.MONITOR1,
    mode      = "preferred",
    position  = "auto",
    scale     = "auto",
})
```

- [ ] **Step 3: Update `config/workspaces.lua`**

Prepend the require and prefix `PRIMARY_MONITOR` and `MONITOR1` with `V.`. Full resulting file:

```lua
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
```

- [ ] **Step 4: Update `config/binds/windows.lua`**

Prepend the require and prefix with `V.`: `MOD_KEY`, `NOCTALIA_CMD`, `MONITOR1`, `MONITOR2`, `MONITOR3`, `NUM_WPM`. The loop locals `key` and the `zoomfunction` parameter `value` stay unqualified. Full resulting file:

```lua
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
```

- [ ] **Step 5: Update `config/binds/launcher.lua`**

Prepend the require; prefix with `V.`: `MOD_KEY`, `NOCTALIA_CMD`, `LAUNCH_PREFIX`, `TERMINAL`, `FILE_MANAGER`, `EDITOR`, `CALCULATOR`, `BROWSER`, `OPENCODE`. Full file:

```lua
-- Launcher bindings
local V = require("config.variables")

------------------
---- LAUNCHER ----
------------------

hl.bind(V.MOD_KEY .. " + Return",      hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.TERMINAL),   { description = "Open terminal" })
hl.bind(V.MOD_KEY .. " + E",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.FILE_MANAGER), { description = "Open file manager" })
hl.bind(V.MOD_KEY .. " + T",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.EDITOR),      { description = "Open text editor" })
hl.bind(V.MOD_KEY .. " + C",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.CALCULATOR),  { description = "Open calculator" })
hl.bind("XF86Calculator",              hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.CALCULATOR),  { description = "Open calculator" })
hl.bind(V.MOD_KEY .. " + B",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.BROWSER),     { description = "Open browser" })
hl.bind(V.MOD_KEY .. " + O",           hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.OPENCODE),    { description = "Open OpenCode" })
hl.bind("CONTROL + SHIFT + Escape",    hl.dsp.exec_cmd(V.LAUNCH_PREFIX .. V.TERMINAL .. " -e btop"), { description = "Open system monitor (btop)" })
hl.bind("CONTROL + ALT + Delete",      hl.dsp.exec_cmd("missioncenter"), { description = "Open Mission Center" })
hl.bind(V.MOD_KEY .. " + Z",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "settings-toggle"), { description = "Toggle settings panel" })
hl.bind(V.MOD_KEY .. " + X",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle control-center"), { description = "Toggle control center" })
hl.bind(V.MOD_KEY .. " + Space",       hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle launcher"), { description = "Open launcher" })
hl.bind(V.MOD_KEY .. " + CTRL + Return", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle launcher"), { description = "Open launcher" })
hl.bind(V.MOD_KEY .. " + period",      hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle launcher /emo"), { description = "Open emoji picker" })
hl.bind(V.MOD_KEY .. " + CTRL + E",    hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle launcher /emo"), { description = "Open emoji picker" })
hl.bind(V.MOD_KEY .. " + L",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "session lock"),  { description = "Lock session" })
hl.bind(V.MOD_KEY .. " + CTRL + L",    hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "session lock"),  { description = "Lock session" })
hl.bind(V.MOD_KEY .. " + ALT + C",     hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle session"), { description = "Toggle session panel" })
```

- [ ] **Step 6: Update `config/binds/hardware.lua`**

Prepend the require; prefix `NOCTALIA_CMD` with `V.`. Full file:

```lua
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
```

- [ ] **Step 7: Update `config/binds/utilities.lua`**

Prepend the require; prefix `MOD_KEY` and `NOCTALIA_CMD`. Full file:

```lua
-- Utility bindings
local V = require("config.variables")

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
hl.bind(V.MOD_KEY .. " + P",       hl.dsp.exec_cmd("hyprpicker -a -n"),       { description = "Pick color" })
hl.bind("Print",                   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-region"), { description = "Capture region" })
hl.bind(V.MOD_KEY .. " + Print",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-fullscreen"), { description = "Capture fullscreen" })
hl.bind(V.MOD_KEY .. " + ALT + F", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-fullscreen"), { description = "Capture fullscreen" })
hl.bind(V.MOD_KEY .. " + ALT + S", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "screenshot-region"), { description = "Capture region" })

-- Theming and Wallpaper
hl.bind(V.MOD_KEY .. " + SHIFT + W", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle wallpaper"), { description = "Open wallpaper picker" })
hl.bind(V.MOD_KEY .. " + CTRL + W",  hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "wallpaper-random"), { description = "Set random wallpaper" })
hl.bind(V.MOD_KEY .. " + SHIFT + M", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "theme-mode-toggle"), { description = "Toggle dark/light theme" })

-- Clipboard
hl.bind(V.MOD_KEY .. " + V", hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle clipboard"), { description = "Open clipboard history" })

-- Notifications
hl.bind(V.MOD_KEY .. " + A",           hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "panel-toggle control-center notifications"), { description = "Open notifications center" })
hl.bind(V.MOD_KEY .. " + CTRL + N",    hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "notification-dnd-toggle"), { description = "Toggle do-not-disturb" })
hl.bind(V.MOD_KEY .. " + SHIFT + N",   hl.dsp.exec_cmd(V.NOCTALIA_CMD .. "notification-clear-active"), { description = "Clear active notifications" })
```

- [ ] **Step 8: Update `config/binds/workspaces.lua`**

Prepend the require; prefix `MOD_KEY`, `MONITOR1`, `MONITOR2`, `MONITOR3`, `NUM_WPM`. Full file:

```lua
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
```

- [ ] **Step 9: Update `config/binds/system.lua`**

Prepend the require; prefix `MOD_KEY` and `NOCTALIA_CMD`. Full file:

```lua
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
```

- [ ] **Step 10: Verify Task 2**

Run:
```bash
luac -p ~/.config/hypr/config/variables.lua ~/.config/hypr/config/monitors.lua ~/.config/hypr/config/workspaces.lua ~/.config/hypr/config/binds/*.lua && echo syntax-OK
```
Expected: `syntax-OK`.

Run:
```bash
rg -n '\b(MOD_KEY|NOCTALIA_CMD|LAUNCH_PREFIX|TERMINAL|FILE_MANAGER|BROWSER|EDITOR|CALCULATOR|OPENCODE|MONITOR1|MONITOR2|MONITOR3|PRIMARY_MONITOR|NUM_WPM)\b' ~/.config/hypr/config --pcre2 -g '*.lua' | rg -v 'V\.|require\("config.variables"\)|local MONITOR|key =|--|comments'
```
Expected: matches only where prefixed `V.` (no bare usage outside `variables.lua`, which is the source file and is exempt).

**Checkpoint reached (no git commit; repo has no git).**

---

### Task 3: Split `windowrules.lua` into four category modules

**Files:**
- Create: `~/.config/hypr/config/windowrules/global.lua`
- Create: `~/.config/hypr/config/windowrules/apps.lua`
- Create: `~/.config/hypr/config/windowrules/gaming.lua`
- Create: `~/.config/hypr/config/windowrules/floats.lua`
- Delete: `~/.config/hypr/config/windowrules.lua`

**Interfaces:**
- Consumes: `require("config.variables")` (only `apps.lua`, for `V.PRIMARY_MONITOR`).
- Produces: four modules registering `hl.window_rule` calls; together they register the exact same rules as the original single file.

- [ ] **Step 1: Create `config/windowrules/global.lua`**

```lua
-- Global window rules — apply regardless of app

-- Generic floating position
hl.window_rule({ match = { float = true }, center = true, persistent_size = true })

-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- Override opacity in favor of terminal settings for opacity. If your terminal doesn't support transparency, you can remove this rule.
hl.window_rule({ match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" }, opacity = "1.0 override" })

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
```

- [ ] **Step 2: Create `config/windowrules/apps.lua`**

```lua
-- Per-app window rules
local V = require("config.variables")

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Apps
hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, monitor = V.PRIMARY_MONITOR, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true, monitor = V.PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, monitor = V.PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(.*[Cc]alc.*)$" }, float = true, size = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" } })
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.kde\\.ark)$" }, size = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" } })
hl.window_rule({ match = { class = "^(.*satty.*)$", title = "^(Satty)$" }, min_size = { "max(monitor_w, monitor_h)*0.35", "min(monitor_w, monitor_h)*0.35" }, float = true })
hl.window_rule({ match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, float = true, size = { "monitor_w*0.70", "monitor_h*0.70" } })
hl.window_rule({
    match = {
        class = "^(org\\.kde\\.dolphin)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
})
```

- [ ] **Step 3: Create `config/windowrules/gaming.lua`**

```lua
-- Gaming window rules
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { xdg_tag = "^(.*game.*)$" }, workspace = gamingWorkspace, fullscreen_state = 2, content = "game", sync_fullscreen = true })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Launching\\.{3})$" }, float = true, center = true, workspace = gamingWorkspace })
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gamingWorkspace,
})
```

- [ ] **Step 4: Create `config/windowrules/floats.lua`**

```lua
-- Floating utility windows & common modals

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end
```

- [ ] **Step 5: Delete the original single file**

```bash
rm ~/.config/hypr/config/windowrules.lua
```

- [ ] **Step 6: Verify Task 3**

Run:
```bash
luac -p ~/.config/hypr/config/windowrules/*.lua && echo syntax-OK
```
Expected: `syntax-OK`.

Rule-count parity (each `hl.window_rule` call registers one rule):
```bash
rg -c 'hl.window_rule' ~/.config/hypr/config/windowrules/*.lua | awk -F: '{s+=$2} END {print "total window_rule calls:", s}'
```
Expected: **26** (5 in global + 10 in apps + 7 in gaming + 4 in floats; the original file registered the same set).

Confirm no file references the old paths:
```bash
rg -n 'config\.windowrules[^.]' ~/.config/hypr
```
Expected: no matches (Task 4 adds the correct dotted requires).

**Checkpoint reached (no git commit; repo has no git).**

---

### Task 4: Rewrite `hyprland.lua` as the three-layer manifest + full runtime verification

**Files:**
- Rewrite: `~/.config/hypr/hyprland.lua`

**Interfaces:**
- Consumes: every module from Tasks 1–3, plus `hyprland-gui` and `noctalia`.

- [ ] **Step 1: Rewrite `hyprland.lua`**

```lua
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
```

- [ ] **Step 2: Syntax-check the manifest**

```bash
luac -p ~/.config/hypr/hyprland.lua && echo syntax-OK
```
Expected: `syntax-OK`.

- [ ] **Step 3: Reload and verify runtime behavior**

Reload config (if a Hyprland session is running):
```bash
hyprctl reload
```
If this config runs through a Lua wrapper (hspr), use the project's reload path (the Noctalia `config-reload` binding) instead; if no session is active, proceed to the file-level checks only.

Then verify:
```bash
hyprctl configerrors
```
Expected: no config errors.

Bind-count parity (expected = number of `hl.bind` calls across the six bind modules):
```bash
rg -c 'hl\.bind' ~/.config/hypr/config/binds/*.lua | awk -F: '{s+=$2} END {print "expected binds:", s}'
hyprctl binds | rg -c '^\s*(SUPER|ALT|SHIFT|CTRL|CONTROL)?'
```
Expected: parity between the count printed and the number of registered binds (allow for wrapper formatting; the meaningful check is that no bind category vanished — spot-check a few: `hyprctl binds | rg 'modmask: 64'` etc. and confirm counts are non-trivial).

Window-rule parity (expected = 26 from Task 3, minus any the wrapper expands):
```bash
hyprctl windowrules
```
Expected: no errors; the rule set from the original windowrules.lua is present.

- [ ] **Step 4: Final visual sweep of the tree**

Run:
```bash
find ~/.config/hypr -name '*.lua' | sort
```
Expected tree:
```
~/.config/hypr/hyprland.lua
~/.config/hypr/hyprland-gui.lua
~/.config/hypr/noctalia.lua
~/.config/hypr/config/animations.lua
~/.config/hypr/config/autostart.lua
~/.config/hypr/config/binds/hardware.lua
~/.config/hypr/config/binds/launcher.lua
~/.config/hypr/config/binds/system.lua
~/.config/hypr/config/binds/utilities.lua
~/.config/hypr/config/binds/windows.lua
~/.config/hypr/config/binds/workspaces.lua
~/.config/hypr/config/colors.lua
~/.config/hypr/config/decorations.lua
~/.config/hypr/config/environment.lua
~/.config/hypr/config/inputs.lua
~/.config/hypr/config/misc.lua
~/.config/hypr/config/monitors.lua
~/.config/hypr/config/variables.lua
~/.config/hypr/config/windowrules/apps.lua
~/.config/hypr/config/windowrules/floats.lua
~/.config/hypr/config/windowrules/gaming.lua
~/.config/hypr/config/windowrules/global.lua
~/.config/hypr/config/workspaces.lua
```
`config/windowrules.lua` and the old `config/binds.lua` must NOT exist.

**Checkpoint reached (no git commit; repo has no git).**

---

## Self-Review Notes

- **Spec coverage:** dependency contract (Tasks 1–2), windowrules split (Task 3), manifest layering (Task 4), override-chain documentation (Task 4 header comments), verification suite (per-task + Task 4 step 3), rollback notes (in spec).
- **Placeholder scan:** every modified file carries its full intended content; no TBD/TODO.
- **Type consistency:** the `V.` / `C.` prefixes and key names (`V.MOD_KEY`, `C.CACHYLGREEN`, `V.PRIMARY_MONITOR`) are identical across tasks; `config.variables` and `config.colors` module paths match requires in Tasks 2–4.