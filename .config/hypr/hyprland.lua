hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 5,
        border_size      = 1,
        col              = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 6,
        rounding_power   = 4,
        active_opacity   = 1.0,
        inactive_opacity = 0.85,

        shadow           = {
            enabled      = false,
            range        = 3,
            render_power = 4,
            color        = 0xee1a1a1a,
        },

        blur             = {
            enabled  = true,
            size     = 6,
            passes   = 3,
            noise    = 0.03,
            vibrancy = 0.1696,
        },
    },

    opengl = {
        nvidia_anti_flicker = true
    },

    ecosystem = {
        no_donation_nag = true
    }

})


require("modules.animations")
require("modules.autostart")
require("modules.bindings")
require("modules.gesture")
require("modules.input")
require("modules.layout")
require("modules.misc")
require("modules.monitor")
require("modules.rules")
