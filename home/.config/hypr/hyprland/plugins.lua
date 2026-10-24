if not hl.plugin.hyprbars then
    return
end

local palette = bar_colors or {
    surface_container = "211F26",
    on_surface        = "E6E0E9",
    primary           = "D0BCFF",
    tertiary          = "EFB8C8",
    error             = "F2B8B5",
}

local actions = {
    close    = "hl.dsp.window.close()",
    maximize = [[hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })]],
    minimize = [[hl.dsp.window.move({ workspace = "special:magic", follow = false })]],
}

local function build_command(action)
    return "hyprctl dispatch '" .. action .. "'"
end

local function add_button(color, action)
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(" .. color .. ")",
        fg_color = "rgb(" .. color .. ")",
        size     = 14,
        icon     = "",
        action   = build_command(action),
    })
end

hl.config({
    plugin = {
        hyprbars = {
            bar_height                 = 40,
            bar_color                  = "rgb(" .. palette.surface_container .. ")",
            col                        = { text = "rgb(" .. palette.on_surface .. ")" },
            bar_text_font              = "Google Sans",
            bar_text_size              = 14,
            bar_text_weight            = "medium",
            bar_text_align             = "left",
            bar_padding                = 16,
            bar_button_padding         = 8,
            bar_precedence_over_border = true,
            on_double_click            = build_command(actions.maximize),
        },
    },
})

add_button(palette.error, actions.close)
add_button(palette.tertiary, actions.maximize)
add_button(palette.primary, actions.minimize)

hl.window_rule({ match = { float = false }, ["hyprbars:no_bar"] = true })
hl.window_rule({ match = { class = "^()$", title = "^()$" }, ["hyprbars:no_bar"] = true })
