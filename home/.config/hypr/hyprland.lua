-- This file sources other files in `hyprland` and `custom` folders
-- You wanna add your stuff in files in `custom`

-- Internal stuff --
require("hyprland.lib")
require("hyprland.services")

-- Environment variables --
require("hyprland.env")
if is_file_exists(HOME .. "/.config/hypr/custom/env.lua") then
    require("custom.env")
end

-- Default configurations --
require("hyprland.execs")
require("hyprland.general")
require("hyprland.rules")
if is_file_exists(HOME .. "/.config/hypr/hyprland/colors.lua") then
    require("hyprland.colors")
end
require("hyprland.keybinds")
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
    require("custom.keybinds")
end

-- Custom configurations --
if is_file_exists(HOME .. "/.config/hypr/custom/execs.lua") then
    require("custom.execs")
end
if is_file_exists(HOME .. "/.config/hypr/custom/general.lua") then
    require("custom.general")
end
if is_file_exists(HOME .. "/.config/hypr/custom/rules.lua") then
    require("custom.rules")
end

-- What the settings app writes, over the defaults and every custom configuration --
if is_file_exists(HOME .. "/.config/hypr/settings.lua") then
    require("settings")
end
local settings = io.popen("ls -1 \"" .. HOME .. "/.config/hypr/settings\" 2>/dev/null")
if settings then
    for name in settings:lines() do
        local area = name:match("^(.+)%.lua$")
        if area then
            require("settings." .. area)
        end
    end
    settings:close()
end

-- Shell overrides --
require("hyprland.shellOverrides.main")
