# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Goal

Build a custom Fedora Atomic (Universal Blue) image that reproduces the current Arch-based desktop setup. Based on the [ublue-os/image-template](https://github.com/ublue-os/image-template). The end result is a bootable OCI image with Hyprland on Fedora Atomic, plus an Arch distrobox container for development tools.

## Key References

- [ublue-os/image-template](https://github.com/ublue-os/image-template) — base template (already cloned)
- [ublue-os/main](https://github.com/ublue-os/main/) — base image (silverblue-main:latest)
- [Current dotfiles](https://github.com/LuisUma92/dotfiles.git) — saved state to reproduce
- [Omarchy install scripts](~/.local/share/omarchy/) — reference for package lists and config structure

## Build System

- `Containerfile` — OCI image definition, `FROM ghcr.io/ublue-os/silverblue-main:latest`. All package installation is inlined as separate `RUN` layers (no external build script). Each domain has its own layer for Docker/Podman layer caching — changing one group only rebuilds that layer and later ones. Layers with `dnf5` use `--mount=type=cache,dst=/var/cache` for package cache reuse across builds.
- `system_files/` — overlay copied directly to `/` in the image (skel configs, helper scripts)
- `.github/workflows/build.yml` — CI pipeline to build and push to GHCR
- `Justfile` — local dev commands (`just build`, `just lint`, `just build-qcow2`, etc.)
- Build locally: `podman build -t omyfendory .`

### Containerfile layer structure

1. **Repo setup** — dnf5-plugins, COPRs (solopasha/hyprland, erikreider/swayosd, atim/lazygit, atim/lazydocker, che/nerd-fonts), mise repo, tailscale repo, negativo17-rar, RPMFusion free+nonfree, gpgcheck fix
2. **Hyprland ecosystem** — hyprland, waybar, mako, uwsm, wofi, grim, etc. (21 packages)
3. **Terminal + fonts** — foot, nerd-fonts, fontawesome, ia-writer, stix-two, twemoji, noto-cjk, lato, fira-code
4. **CLI tools + Firmador** — neovim, tmux, eza, starship, lazygit, mise, java-21-openjdk, firmador.jar
5. **System packages** — hardware (ryzenadj, ddcutil, lm_sensors), audio (ladspa, libfreeaptx), archive (p7zip, rar), btrfs (snapper, btrfs-assistant), waydroid, tailscale, btop, fastfetch, greenboot, etc.
6. **Gaming** — steam, mangohud, winetricks
7. **Remove packages** — firefox, toolbox, gnome-software, GNOME extensions; mask iscsi, wpa_supplicant
8. **Repo cleanup** — disable all COPRs and external repo
9. **Flathub + GDM** — flatpak remote, GDM autologin config
10. **COPY system_files /** — overlay (skel, scripts, services, Firma Digital RPMs)
11. **Firma Digital** — pcsc-lite, patchelf, RPM install, p11-kit module (needs COPY'd files)
12. **Finalize** — chmod scripts, enable all systemd services (pcscd, podman, flatpak-manager, dotfiles-sync, setup-distrobox)
13. **Lint** — `bootc container lint`

## Decisions Made

### Base image: silverblue-main:latest (done)

Switched from bazzite-gnome to vanilla Silverblue via Universal Blue. GNOME variant chosen over KDE because Hyprland ecosystem is GTK-based. Nautilus, nm-applet, gnome-keyring, polkit-gnome, evince, gnome-calculator come included. Light gaming via Steam + winetricks + mangohud (stock Fedora Mesa, no Bazzite patches).

### Display manager: GDM with autologin (done)

GDM comes with Silverblue. Configured for autologin as `luis`, default session `hyprland-uwsm.desktop`. User never sees greeter — boots straight into Hyprland via uwsm.

### Login/lock/idle flow (done)

Plymouth → GDM (autologin) → uwsm starts Hyprland → hypridle monitors inactivity (2.5min lock, 5.5min dpms off) → hyprlock for password prompt. Lid close triggers suspend via systemd-logind.

### Terminal: foot (done)

Keyboard-driven, Wayland-native, delegates tabs/splits to Hyprland+tmux, `foot --server` for instant terminals, minimal RAM, in Fedora repos. Config at `system_files/etc/skel/.config/foot/foot.ini` with Nord colors.

### Power management: AMD laptop (done)

Lenovo IdeaPad Slim 5 15ARP10, Ryzen 7 7735HS, Radeon 680M. Uses amd-pstate-epp driver. power-profiles-daemon + swayosd for visual feedback. brightnessctl for backlight. All supported by standard Fedora kernel.

### Packages added to host image (done)

**Hyprland ecosystem:**
hyprland, hypridle, hyprlock, hyprpicker, hyprsunset, hyprland-qtutils, hyprpolkitagent, xdg-desktop-portal-hyprland, uwsm, waybar, mako, swaybg, swayosd, slurp, satty, wl-clipboard, cliphist, brightnessctl, playerctl, pamixer, wofi, grim

**Terminal + fonts:**
foot, nerd-fonts (via che/nerd-fonts COPR), fontawesome-fonts-all, ia-writer fonts, stix-two-fonts, twitter-twemoji-fonts, google-noto-sans-cjk-fonts, lato-fonts, fira-code-fonts.

**CLI tools (host):**
neovim, tmux, zoxide, eza, fd-find, bat, du-dust, fzf, ripgrep, starship, lazygit, lazydocker, mise, imv, zathura, btop, fastfetch, glow, gum, duf, lshw, topgrade

**System packages (host):**
ryzenadj, ddcutil, i2c-tools, lm_sensors, iio-sensor-proxy, input-remapper, libinput-utils, pulseaudio-utils, libfreeaptx, ladspa-caps-plugins, ladspa-noise-suppression-for-voice, pipewire-module-filter-chain-sofa, p7zip, rar, lzip, libaacs, libbdplus, libbluray, snapper, btrfs-assistant, compsize, waydroid, cage, wlr-randr, tailscale, greenboot, udica, libxcrypt-compat, ydotool, yad, v4l-utils

**Gaming (light):**
steam (RPMFusion), mangohud, winetricks (from GitHub). Stock Fedora Mesa — no Bazzite patches (not worth 30+ version locks for casual gaming on Radeon 680M).

**Removed from base image:**
firefox, toolbox, gnome-software, gnome-classic-session, gnome-tour, gnome-extensions-app, gnome-system-monitor, gnome-initial-setup, GNOME shell extensions. Services masked: iscsi, wpa_supplicant.

**COPRs used (disabled after install):**
solopasha/hyprland, erikreider/swayosd, atim/lazygit, atim/lazydocker, che/nerd-fonts, mise official repo

**External repos (disabled after install):**
RPMFusion free+nonfree, tailscale, negativo17-rar

### Dotfiles overlay (done — step 8)

All configs are standalone with zero Omarchy dependencies. Nord theme inlined everywhere.

**Config files** in `system_files/etc/skel/.config/`:

- `hypr/` — modular: hyprland.conf sources autostart, envs, looknfeel, input, windows, monitors, xdph, hyprsunset, and bindings/{tiling,media,utilities,apps}.conf
- `waybar/` — top bar with workspaces, clock, battery, network, bluetooth, audio
- `mako/config` — notifications with Nord colors, DnD mode
- `foot/foot.ini` — CaskaydiaMono 9pt, Nord colors, block cursor
- `starship.toml` — minimal prompt with git info
- `uwsm/env` — TERMINAL=foot, EDITOR=nvim, mise activation
- `btop/btop.conf` — Nord theme, vim keys, 257 lines
- `nvim/` — LazyVim-based config: init.lua + lua/{config,plugins,snippets,tete} + spell/ + lazy-lock.json (~1.3MB)
- `zathura/zathurarc` — synctex, nvr integration, clipboard

**Other skel files:**

- `.bashrc` — starship, zoxide, fzf, mise init; aliases (eza, bat, dust, duf, lazygit, etc.)
- `.local/share/omarchy/themes/nord/` — btop.theme, icons.theme, neovim.lua, vscode.json, colors.toml, preview.png, backgrounds/
- `.local/share/umas/set432fm.sh` — UMas network config script

**Zen extensions** in `system_files/usr/share/omyfendory/zen-extensions/`:

8 .xpi files (tracked via git LFS): LanguageTool, Zotero, Google Scholar, GNOME Shell Integration, activist-bold colorway, and others. Shipped outside skel because Zen's random profile directory names can't be predicted. The dotfiles-sync script copies them into the user's default Zen profile at boot.

**Helper scripts** in `system_files/usr/bin/`:

- `omyfendory-launch-browser` — Zen Browser via flatpak
- `omyfendory-launch-webapp` — Zen `--blank-window --no-remote` for webapps
- `omyfendory-launch-or-focus` — focus existing window or launch new
- `omyfendory-launch-or-focus-webapp` — same for webapp windows
- `omyfendory-screenshot` — slurp region → grim capture → satty annotate → wl-copy
- `omyfendory-toggle-nightlight` — toggle hyprsunset
- `omyfendory-toggle-idle` — toggle hypridle
- `omyfendory-power-menu` — lock/suspend/reboot/shutdown via wofi
- `omyfendory-setup-arch-dev` — runs `distrobox assemble create`
- `omyfendory-migrate` — user-facing migration script for existing installs (backs up, copies skel + extensions, supports `--dry-run`)

**Note:** `wofi` replaces `walker` as app launcher (walker not packaged for Fedora). Can swap later if walker becomes available via COPR or manual install.

### Flatpak apps (done — step 10)

Systemd oneshot service (`omyfendory-flatpak-manager.service`) installs apps on first boot from `/usr/share/omyfendory/flatpak/install`. Tracks state via sha256 stamp file in `/var/lib/omyfendory/` — only re-runs when the list changes. Flathub remote pre-configured in `Containerfile`.

**Installed apps:** Zen Browser (`app.zen_browser.zen`), Edge, Brave, Spotify, LibreOffice, Obsidian, Zotero, OBS Studio, Inkscape, GNOME Calculator, LocalSend.

**Files:**

- `system_files/usr/share/omyfendory/flatpak/install` — app ID list
- `system_files/usr/libexec/omyfendory-flatpak-manager` — installer script
- `system_files/usr/lib/systemd/system/omyfendory-flatpak-manager.service` — systemd service

### Webapps via Zen Browser (pending — step 11)

Using `zen-browser --blank-window --no-remote` via `omyfendory-launch-webapp` script. Still pending: dedicated WebApp profile with `userChrome.css` for minimal UI (hide tabs, toolbar, URL bar). Zen is a Firefox fork — uses same profile system (`~/.zen/`, `profiles.ini`, `chrome/userChrome.css`). Need `user.js` with `toolkit.legacyUserProfileCustomizations.stylesheets=true` to enable custom CSS. Plan: ship profile in `/etc/skel/.zen/Profiles/webapp/` and reference it via `--profile` flag in launch scripts.

**Webapp bindings** (in `bindings/apps.conf`): ChatGPT, YouTube, WhatsApp, Google Messages, CorreoUCR, Gmail, Gitea, GitHub.

### First-boot dotfiles sync (done — step 12)

`/etc/skel` only populates home directories for **new** accounts. For existing users (e.g. after `bootc switch`), a systemd oneshot service (`omyfendory-dotfiles-sync.service`) runs before GDM. It reads the autologin user from `/etc/gdm/custom.conf`, computes a sha256 stamp of all skel files **and** zen-extensions, and copies `.config/`, `.zen/`, `.local/`, `.bashrc` with `cp -rf` (only runs when hash changes, i.e. new image version). Zen extensions are copied into the user's default Zen profile directory (auto-detected via `profiles.ini` or `*.Default*` glob). Stamp file at `/var/lib/omyfendory/dotfiles-sync.stamp`.

**Files:**

- `system_files/usr/libexec/omyfendory-dotfiles-sync` — sync script
- `system_files/usr/lib/systemd/system/omyfendory-dotfiles-sync.service` — systemd service

### User migration (done)

For existing installs after `bootc upgrade`, users can run `omyfendory-migrate` to manually sync configs without waiting for reboot. It backs up existing configs to `~/.config.bak.<timestamp>/`, copies skel files, syncs Zen extensions, and prints a summary. Supports `--dry-run` to preview changes.

**File:** `system_files/usr/bin/omyfendory-migrate`

### Firma Digital — Costa Rican digital signature (done)

Pre-installed in the image for government and banking use. RPMs and PKCS#11 libraries ship in `system_files/opt/FirmaDigital/` and are installed at build time via `--nodeps` (RHEL 9 RPMs on Fedora 43 — compatible libs, different dep names). Agente GAUDI's SCManager is patched with `patchelf` to link against `libwebkit2gtk-4.1` (Fedora ships 4.1, RPM expects 4.0). Idopte's `libidop11.so` is registered system-wide via p11-kit (`/usr/share/p11-kit/modules/firma-digital.module`). Legacy Athena libs (`libASEP11.so`, `libaseLaserP11.so`) are copied to `/usr/lib64/` with symlinks at `/usr/lib/x64-athena/` and `/usr/lib/` for compatibility. `pcscd.socket` is enabled for on-demand smart card reader access. The `/opt/FirmaDigital/` directory is removed after install to save image space. CA certificates must be installed post-deployment by the user (`update-ca-trust`).

**Firmador** ([firmador.libre.cr](https://firmador.libre.cr/)) — Java-based PDF digital signing tool. Downloaded at build time in `Containerfile` (Layer 4) to `/usr/share/firmador/firmador.jar`. Requires `java-21-openjdk`. A `.desktop` file at `system_files/usr/share/applications/firmador.desktop` makes it launchable from wofi.

### Excluded apps

Signal, Typora, Pinta, Kdenlive, XournalPP, Grok, Basecamp, X — not needed

### Arch distrobox container (done — step 9)

Defined in `system_files/etc/distrobox/arch-dev.ini`. Uses `archlinux:latest` image. Installs via pacman: base-devel, git, clang, llvm, gcc-fortran, cmake, nodejs, npm, rust, python, python-pip, python-poetry, ruby, luarocks, graphviz, tree-sitter-cli, texlive-basic, texlive-latexextra. Builds yay from AUR via init_hooks. Spack is optional manual install (git clone). Convenience script: `omyfendory-setup-arch-dev` runs `distrobox assemble create`.

## Plan Progress

1. ~~Clone image-template repo~~ — done
2. ~~Audit current system~~ — done (230 Arch packages analyzed)
3. ~~Study omarchy scripting approach~~ — done (reviewed install scripts and package lists)
4. ~~Evaluate base image~~ — done (silverblue-main:latest, switched from bazzite-gnome)
5. ~~Decide flatpak vs distrobox vs host~~ — done (see above)
6. ~~Implement Containerfile layers~~ — done (Hyprland stack, CLI tools, nerd-fonts, GDM config)
7. ~~Configure Hyprland dotfiles overlay~~ — done (21 configs + 8 scripts, standalone, Nord theme)
8. ~~Set up distrobox container definition~~ — done (arch-dev.ini + setup script)
9. ~~Set up flatpak auto-install~~ — done (systemd service + flatpak list + manager script)
10. ~~Zen Browser webapp profile~~ — done (userChrome.css hides browser chrome, user.js for webapp defaults, launch script uses `--profile`)
11. ~~First-boot dotfiles sync~~ — done (systemd oneshot copies /etc/skel to user home before GDM)
12. ~~Add missing configs + migration~~ — done (btop, nvim, zathura, omarchy themes, umas, .bashrc, zen extensions, migrate script)

### Disk / encryption notes

- btrfs is default for Fedora Atomic installs; Justfile has `--rootfs=btrfs` for VM builds
- LUKS encryption is an install-time concern, not image-level — handled by Anaconda during OS install
- bootc-image-builder does NOT support LUKS in `customizations.disk` TOML (not implemented)
- For ISO builds, LUKS can be configured via kickstart in `customizations.installer.kickstart` (`autopart --type=btrfs --encrypted`)
- Not relevant for this project since we use `bootc switch` on an already-installed system

### Git remote

Origin: `git@github.com:LuisUma92/Omyfendory.git`
