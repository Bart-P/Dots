from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

import os
import subprocess

mod = "mod4"
terminal = "kitty"


@hook.subscribe.startup_once
def autostart():
    script = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.run([script])


def window_to_next_screen():
    @lazy.function
    def __inner(qtile):
        if qtile.current_window is not None:
            index = qtile.current_screen.index
            if index < len(qtile.screens) - 1:
                qtile.current_window.togroup(qtile.screens[index + 1].group.name)
            else:
                qtile.current_window.togroup(qtile.screens[0].group.name)
        qtile.next_screen()

    return __inner


colors = {
    "bg-darkest": "#11111b",
    "bg-dark": "#181825",
    "bg-lighter": "#45475a",
    "text-light": "#cdd6f4",
    "text-darker": "#6c7086",
    "primary": "#89b4fa",
    "secondary": "#fab387",
    "success": "#a6e3a1",
    "warning": "#f9e2af",
    "danger": "#f38ba8",
}


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.prev_screen(), desc="Move focus to left"),
    Key([mod], "l", lazy.next_screen(), lazy.core.hide_cursor(), desc="Move focus to right"),
    Key([mod], "j", lazy.group.next_window(), desc="Focus next window"),
    Key([mod], "k", lazy.group.prev_window(), desc="Move focus up"),
    Key([mod], "c",
        lazy.spawn("/home/bp/Scripts/rofi/clipboard.sh"),
        desc="Rofi Clipboard Manager"),
    Key([mod], "Return", lazy.layout.swap_main(), desc="Switch to Master"),
    Key([mod], "space",
        lazy.spawn("/home/bp/Scripts/rofi/app_launcher.sh"),
        desc="Rofi App Launcher"),
    Key([mod], "q",
        lazy.spawn("/home/bp/Scripts/rofi/quickactions.sh"),
        desc="Rofi Quickactions"),
    Key([mod], "p",
        lazy.spawn("/home/bp/.config/rofi/bin/powermenu"),
        desc="Rofi Powermenu"),
    Key([mod], "o", window_to_next_screen(),
        desc="Move window to the left"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shrink_main(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.grow_main(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.increase_nmaster(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.spawn(
        terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod, "shift"], "Tab", lazy.next_layout(),
        desc="Toggle between layouts"),
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "w", lazy.spawn('/home/bp/Scripts/rofi/open_app_windows.sh'), desc="Open Windows"),
    Key([mod], "p", lazy.spawn('/home/bp/Scripts/rofi/powermenu.sh'), desc="Spawn Power Menu"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(
                func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                # This part is for active border, if screens are flipped
                # basically a hack to not have an active window an both screens
                lazy.next_screen(),
                lazy.prev_screen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                # same as above in switching to group
                lazy.next_screen(),
                lazy.prev_screen(),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            Key(
                [mod, "control"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc=f"Send focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.MonadTall(
        border_focus=colors["primary"],
        border_normal=colors["bg-dark"],
        border_width=2,
        ratio=0.5,
        margin=10,
        change_ratio=0.05,
        new_client_position="top"
    ),
    layout.Max(
            border_focus=colors["primary"],
            border_normal=colors["bg-dark"],
            border_width=2,
            margin=10
        ),
    # layout.Floating(
    #     border_focus=colors["primary"],
    #     border_normal=colors["bg-dark"],
    #     border_width=2,
    # ),
    # layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="Hack Nerd Font",
    fontsize=18,
    padding=7,
)
extension_defaults = widget_defaults.copy()

layout_icon1 = widget.CurrentLayoutIcon(
                    scale=0.6
                )
layout_icon2 = widget.CurrentLayoutIcon(
                    scale=0.6
                )
task_list1 = widget.TaskList(
                    rounded=False,
                    padding_y=2,
                    padding_x=10,
                    icon_size=0,
                    border=colors["primary"],
                    highlight_method="border",
                    borderwidth=1,
                    margin=3,
                    max_title_width=300,
                )
task_list2 = widget.TaskList(
                    rounded=False,
                    padding_y=3,
                    padding_x=10,
                    icon_size=0,
                    border=colors["primary"],
                    highlight_method="border",
                    borderwidth=1,
                    margin=3,
                    max_title_width=300,
                )
group_box1 = widget.GroupBox(
                    highlight_method='line',
                    disable_drag=True,
                    active=colors["text-light"],
                    inactive=colors["text-darker"],
                    this_current_screen_border=colors["primary"],
                    this_screen_border=colors["text-light"],
                    other_screen_border=colors["bg-lighter"],
                    other_current_screen_border=colors["bg-lighter"],
                )
group_box2 = widget.GroupBox(
                    highlight_method='line',
                    disable_drag=True,
                    active=colors["text-light"],
                    inactive=colors["text-darker"],
                    this_current_screen_border=colors["primary"],
                    this_screen_border=colors["text-light"],
                    other_screen_border=colors["bg-lighter"],
                    other_current_screen_border=colors["bg-lighter"],
                )
prompt = widget.Prompt()
notify = widget.Notify(
                    background_low=colors["warning"],
                    background_urgent=colors["danger"],
                )
systray = widget.Systray()
date = widget.Clock(
        format="%a %d.%m.%y",
        mouse_callbacks={"Button1": lazy.spawn("gnome-calendar")}
        )
clock = widget.Clock(format="%H:%M")
sep = widget.Sep(
        foreground=colors["text-darker"],
        padding=10,
        size_percent=60
        )
powerbutton = widget.TextBox(
        fmt="󰣇",
        foreground=colors["primary"],
        fontsize=21,
        mouse_callbacks={"Button1": lazy.spawn("/home/bp/Scripts/rofi/powermenu.sh")}
        )
spacer = widget.Spacer(length=5)

wallpaper='~/Pictures/Walls/night woods.jpg'

# TODO: start working on post instal script
# FIX?: Notifications - still no bueno, installed all the packages I can remember, and nothing... 

screens = [
    Screen(
        top=bar.Bar(
            [
                powerbutton,
                sep,
                group_box1,
                sep,
                prompt,
                task_list1,
                notify,
                systray,
                sep,
                date,
                sep,
                clock,
                sep,
                layout_icon1,
                spacer
            ],
            32,
            background=colors["bg-dark"],
            margin=[10,10,0,10]
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        wallpaper=wallpaper,
        wallpaper_mode="fill",
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
    Screen(
        top=bar.Bar(
            [
                powerbutton,
                sep,
                group_box2,
                sep,
                prompt,
                task_list2,
                notify,
                sep,
                date,
                sep,
                clock,
                sep,
                layout_icon2,
                spacer
            ],
            32,
            background=colors["bg-dark"],
            margin=[10,10,0,10]
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        wallpaper=wallpaper,
        wallpaper_mode="fill",
    )
]

# Drag floating layouts.
mouse= [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = False
cursor_warp = True
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
    border_focus=colors["primary"],
    border_normal=colors["bg-dark"],
    border_width=2,
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname= "LG3D"
