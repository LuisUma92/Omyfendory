# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Goal

Build a custom Fedora Atomic (Universal Blue) image that reproduces the current Arch-based desktop setup. Based on the [ublue-os/image-template](https://github.com/ublue-os/image-template). The end result is a bootable OCI image with Hyprland on Fedora Atomic, plus an Arch distrobox container for development tools.

## Key References

- [ublue-os/image-template](https://github.com/ublue-os/image-template) — base template (already cloned)
- [ublue-os/bazzite](https://github.com/ublue-os/bazzite/) — base image, provides gaming stack
- [Current dotfiles](https://github.com/LuisUma92/dotfiles.git) — saved state to reproduce
- [Omarchy install scripts](~/.local/share/omarchy/) — reference for package lists and config structure
- `BazziteContainerfile` — copy of bazzite's full Containerfile for reference

## Build System

- `Containerfile` — OCI image definition, `FROM ghcr.io/ublue-os/bazzite-gnome:stable`
- `build_files/build.sh` — main customization script called from Containerfile
- `system_files/` — overlay copied directly to `/` in the image (skel configs, helper scripts)
- `.github/workflows/build.yml` — CI pipeline to build and push to GHCR
- `Justfile` — local dev commands (`just build`, `just lint`, `just build-qcow2`, etc.)
- Build locally: `podman build -t omyfendory .`

## Decisions Made

### Base image: bazzite-gnome:stable (done)
GNOME variant chosen over KDE because Hyprland ecosystem is GTK-based. Nautilus, nm-applet, gnome-keyring, polkit-gnome, evince, gnome-calculator come included. Gaming stack inherited: Steam, Lutris, Gamescope, MangoHud, patched Mesa/PipeWire/Bluez, AMD drivers, ROCm, custom kernel.

### Display manager: GDM with autologin (done)
GDM comes with bazzite-gnome. Configured for autologin as `luis`, default session `hyprland-uwsm.desktop`. User never sees greeter — boots straight into Hyprland via uwsm.

### Login/lock/idle flow (done)
Plymouth → GDM (autologin) → uwsm starts Hyprland → hypridle monitors inactivity (2.5min lock, 5.5min dpms off) → hyprlock for password prompt. Lid close triggers suspend via systemd-logind.

### Terminal: foot (done)
Keyboard-driven, Wayland-native, delegates tabs/splits to Hyprland+tmux, `foot --server` for instant terminals, minimal RAM, in Fedora repos. Config at `system_files/etc/skel/.config/foot/foot.ini` with Nord colors.

### Power management: AMD laptop (done)
Lenovo IdeaPad Slim 5 15ARP10, Ryzen 7 7735HS, Radeon 680M. Uses amd-pstate-epp driver. power-profiles-daemon + swayosd for visual feedback. brightnessctl for backlight. All supported by bazzite kernel.

### Packages added to host image via build.sh (done)

**Hyprland ecosystem:**
hyprland, hypridle, hyprlock, hyprpicker, hyprsunset, hyprland-qtutils, hyprpolkitagent, xdg-desktop-portal-hyprland, uwsm, waybar, mako, swaybg, swayosd, slurp, satty, wl-clipboard, cliphist, brightnessctl, playerctl, pamixer, wofi, grim

**Terminal + fonts:**
foot. Nerd fonts from bazzite base. fontawesome-fonts-all, ia-writer fonts.

**CLI tools (host):**
neovim, tmux, zoxide, eza, fd-find, bat, du-dust, fzf, ripgrep, starship, lazygit, lazydocker, mise, imv, zathura

**COPRs used (disabled after install):**
solopasha/hyprland, erikreider/swayosd, atim/lazygit, atim/lazydocker, mise official repo

### Dotfiles overlay (done — step 8)

All configs are standalone with zero Omarchy dependencies. Nord theme inlined everywhere.

**Config files** in `system_files/etc/skel/.config/`:
- `hypr/` — modular: hyprland.conf sources autostart, envs, looknfeel, input, windows, monitors, xdph, hyprsunset, and bindings/{tiling,media,utilities,apps}.conf
- `waybar/` — top bar with workspaces, clock, battery, network, bluetooth, audio
- `mako/config` — notifications with Nord colors, DnD mode
- `foot/foot.ini` — CaskaydiaMono 9pt, Nord colors, block cursor
- `starship.toml` — minimal prompt with git info
- `uwsm/env` — TERMINAL=foot, EDITOR=nvim, mise activation

**Helper scripts** in `system_files/usr/local/bin/`:
- `omyfendory-launch-browser` — Zen Browser via flatpak
- `omyfendory-launch-webapp` — Zen `--blank-window --no-remote` for webapps
- `omyfendory-launch-or-focus` — focus existing window or launch new
- `omyfendory-launch-or-focus-webapp` — same for webapp windows
- `omyfendory-screenshot` — slurp region → grim capture → satty annotate → wl-copy
- `omyfendory-toggle-nightlight` — toggle hyprsunset
- `omyfendory-toggle-idle` — toggle hypridle
- `omyfendory-power-menu` — lock/suspend/reboot/shutdown via wofi

**Note:** `wofi` replaces `walker` as app launcher (walker not packaged for Fedora). Can swap later if walker becomes available via COPR or manual install.

### Flatpak apps (done — step 10)
Bazzite-style systemd oneshot service (`omyfendory-flatpak-manager.service`) installs apps on first boot from `/usr/share/omyfendory/flatpak/install`. Tracks state via sha256 stamp file in `/var/lib/omyfendory/` — only re-runs when the list changes. Flathub remote pre-configured in `build.sh`.

**Installed apps:** Zen Browser (`app.zen_browser.zen`), Edge, Brave, Spotify, LibreOffice, Obsidian, Zotero, OBS Studio, Inkscape, GNOME Calculator, LocalSend.

**Files:**
- `system_files/usr/share/omyfendory/flatpak/install` — app ID list
- `system_files/usr/libexec/omyfendory-flatpak-manager` — installer script
- `system_files/usr/lib/systemd/system/omyfendory-flatpak-manager.service` — systemd service

### Webapps via Zen Browser (pending — step 11)
Using `zen-browser --blank-window --no-remote` via `omyfendory-launch-webapp` script. Still pending: dedicated WebApp profile with `userChrome.css` for minimal UI (hide tabs, toolbar, URL bar). Zen is a Firefox fork — uses same profile system (`~/.zen/`, `profiles.ini`, `chrome/userChrome.css`). Need `user.js` with `toolkit.legacyUserProfileCustomizations.stylesheets=true` to enable custom CSS. Plan: ship profile in `/etc/skel/.zen/Profiles/webapp/` and reference it via `--profile` flag in launch scripts.

**Webapp bindings** (in `bindings/apps.conf`): ChatGPT, YouTube, WhatsApp, Google Messages, CorreoUCR, Gmail, Gitea, GitHub.

### Excluded apps
Signal, Typora, Pinta, Kdenlive, XournalPP, Grok, Basecamp, X — not needed

### Arch distrobox container (done — step 9)
Defined in `system_files/etc/distrobox/arch-dev.ini`. Uses `archlinux:latest` image. Installs via pacman: base-devel, git, clang, llvm, gcc-fortran, cmake, nodejs, npm, rust, python, python-pip, python-poetry, ruby, luarocks, graphviz, tree-sitter-cli, texlive-basic, texlive-latexextra. Builds yay from AUR via init_hooks. Spack is optional manual install (git clone). Convenience script: `omyfendory-setup-arch-dev` runs `distrobox assemble create`.

## Plan Progress

1. ~~Clone image-template repo~~ — done
2. ~~Audit current system~~ — done (230 Arch packages analyzed)
3. ~~Study omarchy scripting approach~~ — done (reviewed install scripts and package lists)
4. ~~Evaluate base image~~ — done (bazzite-gnome:stable)
5. ~~Decide flatpak vs distrobox vs host~~ — done (see above)
6. ~~Integrate gaming configs from bazzite~~ — done (inherits from base image)
7. ~~Implement build.sh~~ — done (Hyprland stack, CLI tools, GDM config)
8. ~~Configure Hyprland dotfiles overlay~~ — done (21 configs + 8 scripts, standalone, Nord theme)
9. ~~Set up distrobox container definition~~ — done (arch-dev.ini + setup script)
10. ~~Set up flatpak auto-install~~ — done (systemd service + flatpak list + manager script)
11. ~~Zen Browser webapp profile~~ — done (userChrome.css hides browser chrome, user.js for webapp defaults, launch script uses `--profile`)

### Disk / encryption notes
- btrfs is default for Fedora Atomic installs; Justfile has `--rootfs=btrfs` for VM builds
- LUKS encryption is an install-time concern, not image-level — handled by Anaconda during OS install
- bootc-image-builder does NOT support LUKS in `customizations.disk` TOML (not implemented)
- For ISO builds, LUKS can be configured via kickstart in `customizations.installer.kickstart` (`autopart --type=btrfs --encrypted`)
- Not relevant for this project since we use `bootc switch` on an already-installed system

### Git remote
Origin: `git@github.com:LuisUma92/Omyfendory.git`
