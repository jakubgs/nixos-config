# Awesome WM to Hyprland Migration Notes

## Easy Ports

- Keybindings from `.config/awesome/rc.lua` and `.xbindkeysrc` mostly map to Hyprland `bind` lines.
- Named Awesome tags can become named Hyprland workspaces: `:admin:`, `:edit:`, `:web:`, `:comm:`, `:music:`, `:fs:`, `:net:`, `:game:`.
- Window rules map to `windowrulev2`: floating apps, workspace assignment, fullscreen games, centered prompts.
- Border colors, gaps, focus behavior, and fonts mostly map cleanly.
- Autostart maps to `exec-once` or small startup script.

## Main Gaps

- Awesome tags are not identical to Hyprland workspaces. Hyprland does not naturally clone multi-tag view/toggle behavior.
- Awesome layouts do not map exactly. Hyprland core layouts are mainly `dwindle` and `master`; no direct `tile.left`, `tile.top`, or `fair` clone.
- Awesome `wibar` needs replacement, likely Waybar.
- `naughty` notifications and `awesome-client` scripts need rewrite.
- Awesome right-click menu should become a Rofi/Wofi menu or be dropped.
- `run_or_raise` needs a helper using `hyprctl clients`: focus matching window if present, otherwise launch command.

## X Tool Replacements

- `xbindkeys` -> Hyprland `bind`.
- `xrandr`, `autorandr` -> Hyprland `monitor` rules or `kanshi`.
- `xset`, `xautolock`, `slock` -> `hypridle` + `hyprlock`, or `swayidle` + `swaylock`.
- `xinput` touchpad disable -> Hyprland `input { touchpad { enabled = false } }`.
- `setxkbmap` -> Hyprland `input { kb_layout = pl }`.
- `xmodmap`, `xcape` -> Hyprland XKB options if enough, otherwise `keyd` or `kanata`.
- `xbacklight` -> `brightnessctl`.
- `amixer` -> `wpctl` or `pactl` on PipeWire.
- `nitrogen` -> `hyprpaper` or `swaybg`.
- `flameshot gui` -> may work via portal; if not, use `grim` + `slurp` + `swappy`.

## Autostart Notes

Current `bin/autostart` is X-heavy. Keep structure, but replace X commands before using it under Hyprland:

- Remove or guard `xset`, `setxkbmap`, `xinput`, `xkbset`, `xmodmap`, `xcape`, `nitrogen`, `autorandr`, `xbindkeys`, `xautolock`.
- Keep applets if they work under Wayland/XWayland: `blueman-applet`, `nm-applet`, `pasystray` if still wanted.
- Prefer Hyprland-native `exec-once` for core session pieces.

## Bar Plan

Use Waybar as closest replacement for current Awesome top bar:

- Left: launcher shortcut, workspaces, layout indicator if useful.
- Center: task/window module.
- Right: battery, clock, tray.

Theme target:

- Font: `Inconsolata 14`.
- Background: `#000000`.
- Foreground: `#aaaaaa` / focused `#ffffff`.
- Border focus: `#4d9cf6`.

## Notification Plan

Replace `bin/anotify`, currently tied to Awesome `naughty` and `awesome-client`.

Simplest path:

- Use `notify-send`.
- Run `mako`, `dunst`, or `swaync` as notification daemon.
- Preserve flags like `-w`, `-e`, `-m`, `-p` as shell formatting around `notify-send`.

More exact path:

- Use a daemon with actions.
- Recreate click actions for email/syslog/pass notifications.

## Terminal Note

`urxvtc` can run through XWayland, but it is not Wayland-native. Keeping it is possible for transition, but clipboard, scaling, and input may be less clean.

Closest simple/light replacement candidate: `foot`.

- Wayland-native.
- Small, fast startup.
- Daemon/server mode exists: `foot --server` plus `footclient`, similar idea to `urxvtd` + `urxvtc`.
- Config is simple INI-style.
- Good fit if goal is light, boring, fast terminal.

Other candidates:

- `alacritty`: simple config, fast, but no daemon/client model and GPU-oriented.
- `kitty`: feature-rich and fast enough, but larger and more complex than wanted.
- `wezterm`: powerful, but too heavy/complex for this preference.

## Recommended Migration Order

1. Start Hyprland with monitor, input, env, and minimal binds.
2. Port core Awesome keybindings.
3. Port `.xbindkeysrc` media/screen/power binds with Wayland-native commands.
4. Replace X autostart pieces.
5. Add Waybar.
6. Add window rules.
7. Add `run_or_raise` helper.
8. Rewrite `anotify` only after rest works.
