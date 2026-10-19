# dotfiles

My personal dotfiles for a Linux desktop built around Hyprland and a custom
Quickshell shell.

The repository mirrors my home directory: everything is laid out where it
belongs in use (`.config/`, `.local/`, `.ssh/`, and files such as `.zshenv`
and `.profile` at the root), and GNU Stow links it into place.
`.stow-local-ignore` keeps Git and editor files out of the linked result.

## What's inside

### Desktop

- **Hyprland** (`.config/hypr/`) — the main configuration is in Lua
  (`hyprland.lua`), split into modules under `modules/` for animations,
  autostart, bindings, gestures, input, layout, monitor, and window rules.
  The same folder holds `hypridle.conf`, `hyprlock.conf`, and
  `hyprsunset.conf`.
- **Quickshell** (`.config/quickshell/`) — a custom shell that starts at
  `shell.qml`. Its components cover workspaces, clock, date, window title,
  language, tray, menu, volume, a media player, and a lyrics overlay, plus a
  network section with a Wi-Fi list and a network panel. Overlays provide the
  volume OSD and corner curves. Services handle lyrics (with an LRC parser)
  and Matugen, and there are shared `config/` and `colors/` folders.
  Recent work here added multi-player support to the player component, an
  animated volume OSD, a restyled lyrics overlay, and a new network manager
  window, and removed the NetworkManager applet from autostart.
- **Waybar** (`.config/waybar/`) — a Waybar configuration is also included,
  along with configurations for Sway (`.config/sway/`) and Mango
  (`.config/mango/`).
- **Launchers and notifications** — rofi, fuzzel, and mako.
- **Theming** — Matugen (`.config/matugen/`), GTK 3 and GTK 4, qt5ct, qt6ct,
  fontconfig, and nwg-look.

### Terminal and editors

- **Terminals** — foot and kitty.
- **Editors** — Neovim, Zed, and Vim.
- **Shell** — Zsh, with `.zshenv` at the root and more under `.config/zsh/`.
- **Git** — configuration under `.config/git/`.

### Apps and everyday tools

- **Music and video** — mpd, rmpc, and mpv.
- **Browsers and Electron apps** — flag files in `.config/` for Brave, Chrome,
  Chromium, and Helium, plus `code-flags.conf` and `electron-flags.conf`.
- **Other tools** — configurations are also included for atac, btcl, btop,
  husky, lxqt, networkmanager-dmenu, and swayimg, among others.

### Scripts

`.local/bin/` holds small helper scripts, including:

- Wallpaper: `cycle-wallpaper`, `random-wallpaper`, and
  `get-random-wallpaper`
- Music: `next-song`, `prev-song`, `toggle-play`, `play-next`,
  `select-play-next`, and `music-artist-separate-combine.py`
- Volume: `volume-up` and `volume-down`
- Clipboard and theming: `cliphist-rofi-img`, `update-colors`, and
  `link-zen-profile-with-matugen`
- Other helpers: `scene-render-blender` and `start-waybar`

## Layout

```text
.
├── .config/             # most desktop and application configuration
├── .local/bin/          # personal scripts
├── .ssh/                # SSH config only — no keys
├── .profile
├── .zshenv
└── .stow-local-ignore
```

## Install

```sh
git clone https://github.com/aligheisar/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .
```

This links the files into your home directory. Back up your existing
configuration first, and review anything you do not want replaced.

These are personal settings written for my own machine and workflow, so
expect to adjust paths, preferences, and choices to fit yours.
