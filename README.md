# Omyfendory

A custom [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) desktop image built on [Bazzite](https://bazzite.gg/), featuring Hyprland as the window manager, a curated set of CLI tools, and the full Bazzite gaming stack. Delivered as a bootable OCI container via [Universal Blue](https://universal-blue.org/).

## What's Inside

### Base: Bazzite GNOME

Inherits the complete Bazzite gaming stack — Steam, Lutris, Gamescope, MangoHud, patched Mesa/PipeWire/Bluez, AMD drivers, ROCm, and a custom kernel.

### Hyprland Desktop

| Component | Role |
|---|---|
| [Hyprland](https://hyprland.org/) | Tiling Wayland compositor |
| [uwsm](https://github.com/Vladimir-csp/uwsm) | Session manager (launched from GDM) |
| [Waybar](https://github.com/Alexays/Waybar) | Top bar (workspaces, clock, battery, network, audio) |
| [wofi](https://hg.sr.ht/~scoopta/wofi) | App launcher (`Super+Space`) |
| [mako](https://github.com/emersion/mako) | Notifications (Nord theme, DnD mode) |
| [foot](https://codeberg.org/dnkl/foot) | Terminal (Wayland-native, fast) |
| [hypridle](https://github.com/hyprwm/hypridle) + [hyprlock](https://github.com/hyprwm/hyprlock) | Idle management and lock screen |
| [hyprsunset](https://github.com/hyprwm/hyprsunset) | Night light |
| [swaybg](https://github.com/swaywm/swaybg) | Wallpaper |
| [swayosd](https://github.com/ErikReider/SwayOSD) | Volume/brightness OSD |
| [grim](https://sr.ht/~emersion/grim/) + [slurp](https://github.com/emersion/slurp) + [satty](https://github.com/gabm/Satty) | Screenshot pipeline |

### CLI Tools

neovim, tmux, zoxide, eza, fd-find, bat, du-dust, fzf, ripgrep, starship, lazygit, lazydocker, mise, imv, zathura

### Flatpak Apps (auto-installed on first boot)

Zen Browser, Microsoft Edge, Brave, Obsidian, LibreOffice, Zotero, Spotify, OBS Studio, Inkscape, GNOME Calculator, LocalSend

### Development Container

An Arch Linux [distrobox](https://distrobox.it/) container (`arch-dev`) with compilers (clang, gcc, rust, cmake), languages (Node.js, Python, Ruby), and [yay](https://github.com/Jguer/yay) for AUR access.

## Installation

### Switch an existing Fedora Atomic / Bazzite system

```bash
sudo bootc switch ghcr.io/LuisUma92/omyfendory:latest
systemctl reboot
```

The system will reboot into Hyprland with GDM autologin. Flatpak apps install automatically on first boot (requires network).

### Set up the dev container (optional, one-time)

```bash
omyfendory-setup-arch-dev
```

This creates the `arch-dev` distrobox. Enter it with:

```bash
distrobox enter arch-dev
```

## Keyboard Shortcuts

### Window Management

| Shortcut | Action |
|---|---|
| `Super+Q` | Close window |
| `Super+J` | Toggle split |
| `Super+Shift+V` | Toggle floating |
| `Shift+F11` | Fullscreen |
| `Super+Arrow` | Move focus |
| `Super+Shift+Arrow` | Swap window |
| `Super+1-0` | Switch workspace |
| `Super+Shift+1-0` | Move window to workspace |
| `Super+Tab / Shift+Tab` | Next / previous workspace |
| `Alt+Tab` | Cycle windows |
| `Super+- / +` | Resize width |
| `Super+Mouse drag` | Move / resize window |

### Apps

| Shortcut | Action |
|---|---|
| `Super+Return` | Terminal (foot) |
| `Super+Space` | App launcher (wofi) |
| `Super+B` | Browser (Zen) |
| `Super+F` | File manager (Nautilus) |
| `Super+N` | Neovim |
| `Super+M` | Spotify |
| `Super+O` | Obsidian |
| `Super+E` | Edge |
| `Super+I` | Inkscape |
| `Super+Z` | Zotero |
| `Super+D` | PDF viewer (zathura) |
| `Super+A` | ChatGPT |
| `Super+Y` | YouTube |
| `Super+W` | WhatsApp |

### System

| Shortcut | Action |
|---|---|
| `Super+Ctrl+L` | Lock screen |
| `Super+Ctrl+N` | Toggle night light |
| `Super+Ctrl+I` | Toggle idle lock |
| `Super+Shift+Space` | Toggle waybar |
| `Super+Comma` | Dismiss notification |
| `Super+Backspace` | Toggle window transparency |
| `Print` | Screenshot region |
| `Super+Print` | Color picker |
| `XF86PowerOff` | Power menu |
| `Super+Escape` | Logout |

### Media

Volume, brightness, and media keys work natively. Hold `Alt` for fine adjustments (+1 increments).

## Building Locally

Requires [Podman](https://podman.io/) and [Just](https://just.systems/).

```bash
# Build the OCI image
just build

# Build a QCOW2 VM image for testing
just build-qcow2

# Run the VM
just run-vm-qcow2

# Lint shell scripts
just lint
```

## Repository Structure

```
Containerfile                       # OCI image definition
build_files/
  build.sh                          # Package installs, COPR setup, service enablement
system_files/                       # Overlay copied to / in the image
  etc/
    distrobox/arch-dev.ini           # Arch dev container definition
    skel/.config/
      hypr/                          # Hyprland config (modular)
      waybar/                        # Bar config + styling
      mako/config                    # Notification daemon
      foot/foot.ini                  # Terminal
      starship.toml                  # Shell prompt
      uwsm/env                      # Session environment
  usr/
    lib/systemd/system/
      omyfendory-flatpak-manager.service
    libexec/
      omyfendory-flatpak-manager     # First-boot Flatpak installer
    local/bin/
      omyfendory-launch-browser      # Zen Browser launcher
      omyfendory-launch-webapp       # Webapp mode launcher
      omyfendory-launch-or-focus     # Focus-or-launch helper
      omyfendory-power-menu          # Lock/suspend/reboot/shutdown
      omyfendory-screenshot          # Region screenshot pipeline
      omyfendory-toggle-nightlight   # Hyprsunset toggle
      omyfendory-toggle-idle         # Hypridle toggle
      omyfendory-setup-arch-dev      # Distrobox setup script
    share/omyfendory/flatpak/
      install                        # Flatpak app list
.github/workflows/
  build.yml                          # CI: build, push to GHCR, sign with cosign
Justfile                             # Local dev commands
```

## Customization

### Change Flatpak apps

Edit `system_files/usr/share/omyfendory/flatpak/install` — one Flatpak app ID per line. The manager re-runs automatically when the list changes.

### Change Hyprland keybindings

Edit the files under `system_files/etc/skel/.config/hypr/bindings/`:
- `apps.conf` — app launch shortcuts
- `tiling.conf` — window/workspace management
- `media.conf` — volume, brightness, media keys
- `utilities.conf` — system utilities, screenshots, notifications

### Add host packages

Add `dnf5 -y install <package>` to `build_files/build.sh`.

### Add dev tools

Edit the `additional_packages` line in `system_files/etc/distrobox/arch-dev.ini`.

## How It Works

1. **Build time** (`Containerfile` + `build.sh`): installs RPM packages from Fedora repos and COPRs, configures GDM autologin, enables services, pre-configures Flathub remote.
2. **Image delivery**: CI builds the OCI image daily, pushes to GHCR, signs with cosign.
3. **First boot**: `omyfendory-flatpak-manager.service` installs all Flatpak apps. A sha256 stamp file ensures it only re-runs when the app list changes.
4. **Updates**: `bootc upgrade` pulls the latest image atomically. Rollback with `bootc rollback`.

## Credits

Built on top of [Universal Blue](https://universal-blue.org/) and [Bazzite](https://bazzite.gg/). Started from the [ublue-os/image-template](https://github.com/ublue-os/image-template).
