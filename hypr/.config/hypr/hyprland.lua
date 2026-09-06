local terminal = "kitty"
local rofiScripts = os.getenv("HOME") .. "/Scripts/rofi"
local mainMod = "SUPER"

-- Keep the physical desktop stable instead of relying on connector discovery order.
hl.monitor({
    output = "DP-3",
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-4",
    mode = "preferred",
    position = "2560x0",
    scale = 1,
})

hl.workspace_rule({ workspace = "1", monitor = "DP-3", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-4", default = true, persistent = true })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = "rgba(89b4faff)",
            inactive_border = "rgba(181825ff)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },

    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },

    animations = {
        enabled = false,
    },

    master = {
        mfact = 0.5,
        new_status = "master",
        new_on_top = true,
        orientation = "left",
    },

    input = {
        kb_layout = "de",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },

    binds = {
        window_direction_monitor_fallback = false,
    },

    cursor = {
        warp_on_change_workspace = 1,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        focus_on_activate = true,
    },
})

local function startOnce(process, command)
    hl.dispatch(hl.dsp.exec_cmd("pgrep -x '" .. process .. "' >/dev/null || " .. command))
end

hl.on("hyprland.start", function()
    startOnce("waybar", "waybar")
    startOnce("hyprpaper", "hyprpaper")
    startOnce("mako", "mako")
    startOnce("wl-paste", "wl-paste --watch cliphist store")
    startOnce("blueman-applet", "blueman-applet")
    startOnce("nm-applet", "nm-applet")
    startOnce("volctl", "volctl")
end)

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Qtile-style focus and layout controls.
hl.bind(mainMod .. " + H", hl.dsp.focus({ monitor = "-1" }), { description = "Focus previous monitor" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ monitor = "+1" }), { description = "Focus next monitor" })
hl.bind(mainMod .. " + J", hl.dsp.window.cycle_next({ next = true }), { description = "Focus next window" })
hl.bind(mainMod .. " + K", hl.dsp.window.cycle_next({ next = false }), { description = "Focus previous window" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "Toggle bar" })
hl.bind(mainMod .. " + RETURN", hl.dsp.layout("swapwithmaster master"), { description = "Swap with master" })
hl.bind(mainMod .. " + N", hl.dsp.layout("mfact exact 0.5"), { description = "Reset master ratio" })

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("mfact -0.05"), { repeating = true, description = "Shrink master" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("mfact +0.05"), { repeating = true, description = "Grow master" })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ next = true }), { description = "Move window down" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ prev = true }), { description = "Move window up" })
hl.bind(mainMod .. " + CONTROL + H", hl.dsp.layout("addmaster"), { description = "Add master window" })
hl.bind(mainMod .. " + CONTROL + L", hl.dsp.layout("removemaster"), { description = "Remove master window" })
hl.bind(mainMod .. " + CONTROL + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true, description = "Grow window down" })
hl.bind(mainMod .. " + CONTROL + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true, description = "Grow window up" })

-- Applications and session controls.
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(terminal), { description = "Open terminal" })
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(rofiScripts .. "/app_launcher.sh"), { description = "Open app launcher" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(rofiScripts .. "/clipboard.sh"), { description = "Open clipboard" })
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(rofiScripts .. "/quickactions.sh"), { description = "Open quick actions" })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(rofiScripts .. "/powermenu.sh"), { description = "Open power menu" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(rofiScripts .. "/open_app_windows.sh"), { description = "Open window switcher" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show run -p Run -theme ~/.config/rofi/themes/launcher.rasi"), { description = "Run command" })
hl.bind(mainMod .. " + O", hl.dsp.window.move({ monitor = "+1", follow = true }), { description = "Move window to next monitor" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m region -o Pictures/Screenshots/"), { description = "Screenshot region" })
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Toggle maximized window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. " + CONTROL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })
hl.bind(mainMod .. " + CONTROL + Q", hl.dsp.exit(), { description = "Exit Hyprland" })

-- Use evdev keycodes so German Shift symbols do not break workspace movement.
local workspaceKeys = { 10, 11, 12, 13, 14, 15, 16, 17, 18 }

local function moveWindowToWorkspaceOnCurrentMonitor(workspace)
    return function()
        local window = hl.get_active_window()
        if not window then
            return
        end

        local result = hl.dispatch(hl.dsp.focus({ workspace = workspace, on_current_monitor = true }))
        if result and result.ok == false then
            return result
        end

        return hl.dispatch(hl.dsp.window.move({ workspace = workspace, follow = true, window = window }))
    end
end

for workspace, keycode in ipairs(workspaceKeys) do
    local key = "code:" .. keycode
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace, on_current_monitor = true }), { description = "Focus workspace " .. workspace })
    hl.bind(mainMod .. " + SHIFT + " .. key, moveWindowToWorkspaceOnCurrentMonitor(workspace), { description = "Move to workspace " .. workspace })
    hl.bind(mainMod .. " + CONTROL + " .. key, hl.dsp.window.move({ workspace = workspace, follow = false }), { description = "Send to workspace " .. workspace })
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.window_rule({
    name = "float-qtile-utilities",
    match = { class = "(?i)^(gnome-calculator|org.gnome.Calculator|gnome-calendar|org.gnome.Calendar|zoiper|pinentry.*|ssh-askpass)$" },
    float = true,
})

hl.window_rule({
    name = "float-qtile-dialogs",
    match = { title = "(?i)^(branchdialog|pinentry)$" },
    float = true,
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})
