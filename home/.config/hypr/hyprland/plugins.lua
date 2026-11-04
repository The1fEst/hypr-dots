local is_loaded = false
for _, plugin in ipairs(hl.get_loaded_plugins()) do
    if plugin.name == "proscenio_bars" then
        is_loaded = true
    end
end
if not is_loaded then
    return
end

local palette = {
    surface_container         = "211F26",
    surface_container_low     = "1D1B20",
    surface_container_highest = "36343B",
    on_surface                = "E6E0E9",
    on_surface_variant        = "CAC4D0",
    primary                   = "D0BCFF",
    on_primary                = "381E72",
    tertiary                  = "EFB8C8",
    on_tertiary               = "492532",
    error                     = "F2B8B5",
    on_error                  = "601410",
}
for role, color in pairs(bar_colors or {}) do
    palette[role] = color
end

local function rgb(role)
    return "rgb(" .. palette[role] .. ")"
end

hl.config({
    plugin = {
        proscenio_bars = {
            bar_height            = 40,
            title_font            = "Google Sans",
            title_size            = 14,
            title_weight          = "medium",
            bar_color             = rgb("surface_container"),
            title_color           = rgb("on_surface"),
            inactive_bar_color    = rgb("surface_container_low"),
            inactive_title_color  = rgb("on_surface_variant"),
            inactive_button_color = rgb("surface_container_highest"),
            close_color           = rgb("error"),
            close_icon_color      = rgb("on_error"),
            minimize_color        = rgb("tertiary"),
            minimize_icon_color   = rgb("on_tertiary"),
            maximize_color        = rgb("primary"),
            maximize_icon_color   = rgb("on_primary"),
        },
    },
})

hl.window_rule({ match = { class = "^()$", title = "^()$" }, ["proscenio_bars:no_bar"] = true })
hl.window_rule({ match = { class = "^(dev\\.fEst\\.Proscenio)$" }, ["proscenio_bars:no_bar"] = true })
