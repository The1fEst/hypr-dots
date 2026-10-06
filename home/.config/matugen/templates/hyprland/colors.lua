border_colors = {
    active          = "{{colors.outline_variant.default.hex_stripped}}",
    inactive        = "{{colors.surface_container_low.default.hex_stripped}}",
    outline         = "{{colors.outline.default.hex_stripped}}",
    outline_variant = "{{colors.outline_variant.default.hex_stripped}}",
    primary         = "{{colors.primary.default.hex_stripped}}",
    secondary       = "{{colors.secondary.default.hex_stripped}}",
    tertiary        = "{{colors.tertiary.default.hex_stripped}}",
}

hl.config({
    general = {
        col = {
            active_border   = "rgba(" .. border_colors.active .. "77)",
            inactive_border = "rgba(" .. border_colors.inactive .. "33)",
        },
    },
    misc = {
        background_color = "rgba({{colors.surface.dark.hex_stripped}}FF)",
    },
})

hl.window_rule({
    match        = { pin = 1 },
    border_color = "rgba({{colors.primary.default.hex_stripped}}AA) rgba({{colors.primary.default.hex_stripped}}77)",
})
