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