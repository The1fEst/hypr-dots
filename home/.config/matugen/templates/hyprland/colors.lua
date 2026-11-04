border_colors = {
    active          = "{{colors.outline_variant.default.hex_stripped}}",
    inactive        = "{{colors.surface_container_low.default.hex_stripped}}",
    outline         = "{{colors.outline.default.hex_stripped}}",
    outline_variant = "{{colors.outline_variant.default.hex_stripped}}",
    primary         = "{{colors.primary.default.hex_stripped}}",
    secondary       = "{{colors.secondary.default.hex_stripped}}",
    tertiary        = "{{colors.tertiary.default.hex_stripped}}",
}

bar_colors = {
    surface_container         = "{{colors.surface_container.default.hex_stripped}}",
    surface_container_low     = "{{colors.surface_container_low.default.hex_stripped}}",
    surface_container_highest = "{{colors.surface_container_highest.default.hex_stripped}}",
    on_surface                = "{{colors.on_surface.default.hex_stripped}}",
    on_surface_variant        = "{{colors.on_surface_variant.default.hex_stripped}}",
    primary                   = "{{colors.primary.default.hex_stripped}}",
    on_primary                = "{{colors.on_primary.default.hex_stripped}}",
    tertiary                  = "{{colors.tertiary.default.hex_stripped}}",
    on_tertiary               = "{{colors.on_tertiary.default.hex_stripped}}",
    error                     = "{{colors.error.default.hex_stripped}}",
    on_error                  = "{{colors.on_error.default.hex_stripped}}",
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
