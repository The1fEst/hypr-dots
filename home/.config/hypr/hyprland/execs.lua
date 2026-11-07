-- put former exec-once commands inside the func and former exec commands outside
hl.on("hyprland.start", function ()

    -- Bar, wallpaper
    hl.exec_cmd("$HOME/.config/hypr/hyprland/scripts/start_geoclue_agent.sh")
    -- The target is what the rest of the session hangs off: binding to
    -- graphical-session.target is what starts the portals and the autostarted apps.
    -- proscenio is named as well so that it comes up even where enabling it failed.
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd --all && systemctl --user reset-failed && systemctl --user start hyprland-session.target proscenio.service")
    hl.exec_cmd("$HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh")

    -- Cursor: follow XCURSOR_* so custom/env.lua wins instead of racing this line
    hl.exec_cmd("hyprctl setcursor \"${XCURSOR_THEME:-Bibata-Modern-Ice}\" \"${XCURSOR_SIZE:-36}\"")
end)
