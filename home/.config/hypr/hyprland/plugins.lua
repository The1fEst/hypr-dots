if not hl.plugin.hyprbars then
    return
end

local palette = {
    surface_container = "211F26",
    on_surface        = "E6E0E9",
    tertiary          = "EFB8C8",
    error             = "F2B8B5",
}
for role, color in pairs(bar_colors or {}) do
    palette[role] = color
end

local actions = {
    close    = "hl.dsp.window.close()",
    maximize = [[hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })]],
}

local function build_command(action)
    return "hyprctl dispatch '" .. action .. "'"
end

local function add_button(background, foreground, action)
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(" .. background .. ")",
        fg_color = "rgb(" .. foreground .. ")",
        size     = 16,
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
            bar_text_align             = "center",
            bar_padding                = 16,
            bar_button_padding         = 8,
            bar_precedence_over_border = true,
            on_double_click            = build_command(actions.maximize),
        },
    },
})

add_button(palette.error, palette.surface_container, actions.close)
add_button(palette.tertiary, palette.surface_container, actions.maximize)

hl.window_rule({ match = { float = false }, ["hyprbars:no_bar"] = true })
hl.window_rule({ match = { class = "^()$", title = "^()$" }, ["hyprbars:no_bar"] = true })
hl.window_rule({ match = { class = "^(dev\\.fEst\\.Proscenio)$" }, ["hyprbars:no_bar"] = true })
