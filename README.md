# Omyfendory

A custom [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) desktop image built on [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) via [Universal Blue](https://universal-blue.org/), featuring Hyprland as the window manager and a curated set of CLI tools. Delivered as a bootable OCI container.

## What's Inside

### Base: Fedora Silverblue (Universal Blue)

Vanilla GNOME desktop with Fedora Atomic foundations — immutable base OS, automatic updates via `bootc`, Flatpak for GUI apps, and Wayland by default.

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

### Firma Digital (Costa Rica)

Pre-installed digital signature stack for Costa Rican government and banking services:
- **Firmador** — PDF digital signing application ([firmador.libre.cr](https://firmador.libre.cr/))
- **Idopte middleware** — PKCS#11 smart card driver (`libidop11.so`)
- **Agente GAUDI** — authentication broker for BCCR/banking portals
- **Legacy Athena libraries** — `libASEP11.so` for older government applets
- **pcscd** — smart card reader daemon (auto-starts on card insertion)

Firmador is available from wofi (`Super+Space`). The PKCS#11 module is registered system-wide via p11-kit — browsers detect the smart card automatically.

## Installation

### Switch an existing Fedora Atomic system

```bash
cosign verify --key cosign.pub ghcr.io/luisuma92/omyfendory:latest  # optional: verify signature
sudo bootc switch ghcr.io/luisuma92/omyfendory:latest
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

### Set up Firma Digital credentials (required for digital signature)

1. Copy the CA certificate chain (`.cer` or `.crt` files from BCCR/SINPE) to the system trust store:

   ```bash
   sudo cp /path/to/your/ca-certificates/*.cer /usr/share/pki/ca-trust-source/anchors/
   sudo update-ca-trust
   ```

2. Plug in your USB smart card reader and insert your Firma Digital card.

3. Verify the card is detected:

   ```bash
   pcsc_scan
   ```

   You should see your card reader and card ATR listed.

4. The PKCS#11 module is pre-configured via p11-kit. Zen Browser (and any NSS-based app) will detect the smart card automatically under Security Devices. No manual module loading needed.

## Keyboard Shortcuts

### Window Management

| Shortcut | Action |
|---|---|
| `Super+Q` | Close window |
| `Ctrl+Alt+Delete` | Close all windows |
| `Super+J` | Toggle split |
| `Super+P` | Pseudo window |
| `Super+Shift+V` | Toggle floating |
| `Shift+F11` | Fullscreen |
| `Alt+F11` | Full width |
| `Super+Arrow` | Move focus |
| `Super+Shift+Arrow` | Swap window |
| `Super+1-0` | Switch workspace |
| `Super+Shift+1-0` | Move window to workspace |
| `Super+Tab / Shift+Tab` | Next / previous workspace |
| `Super+Ctrl+Tab` | Former workspace |
| `Alt+Tab` | Cycle windows |
| `Super+- / =` | Resize width |
| `Super+Shift+- / =` | Resize height |
| `Super+Mouse scroll` | Scroll workspaces |
| `Super+Left-drag` | Move window |
| `Super+Right-drag` | Resize window |

### Apps

| Shortcut | Action |
|---|---|
| `Super+Return` | Terminal (foot) |
| `Super+Space` | App launcher (wofi) |
| `Super+B` | Browser (Zen) |
| `Super+Shift+B` | Browser private window |
| `Super+F` | File manager (Nautilus) |
| `Super+N` | Neovim |
| `Super+T` | Activity monitor (btop) |
| `Super+M` | Spotify |
| `Super+O` | Obsidian |
| `Super+E` | Edge |
| `Super+I` | Inkscape |
| `Super+Z` | Zotero |
| `Super+D` | PDF viewer (zathura) |
| `Super+/` | 1Password |
| `Super+Shift+D` | Docker (lazydocker) |
| `Super+Shift+P` | Python REPL |
| `Super+A` | ChatGPT |
| `Super+Y` | YouTube |
| `Super+W` | WhatsApp |
| `Super+Alt+G` | Google Messages |
| `Super+C` | CorreoUCR |
| `Super+Shift+C` | Gmail |
| `Super+G` | Gitea |
| `Super+Shift+G` | GitHub |
| `Super+Ctrl+V` | Clipboard history |
| `Super+Alt+C / V / X` | Universal copy / paste / cut |

### System

| Shortcut | Action |
|---|---|
| `Super+Ctrl+L` | Lock screen |
| `Super+Ctrl+N` | Toggle night light |
| `Super+Ctrl+I` | Toggle idle lock |
| `Super+Shift+Space` | Toggle waybar |
| `Super+Comma` | Dismiss notification |
| `Super+Shift+Comma` | Dismiss all notifications |
| `Super+Alt+Comma` | Invoke notification |
| `Super+Ctrl+Comma` | Toggle Do Not Disturb |
| `Super+Backspace` | Toggle window transparency |
| `Print` | Screenshot region |
| `Super+Print` | Color picker |
| `Super+Ctrl+Z` | Zoom in |
| `Super+Ctrl+Alt+Z` | Reset zoom |
| `Super+Ctrl+Alt+T` | Show time |
| `Super+Ctrl+Alt+B` | Show battery |
| `XF86Calculator` | Calculator |
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
    skel/.zen/Profiles/webapp/         # Zen Browser webapp profile
      chrome/userChrome.css            # Hides browser chrome for webapp mode
      user.js                          # Webapp-friendly defaults
  opt/FirmaDigital/                    # Firma Digital installers (removed after build)
    Agente GAUDI/*.rpm                 # BCCR authentication broker
    Idopte/*.rpm                       # PKCS#11 middleware
    Librería/*.so                      # Legacy Athena PKCS#11 libraries
  usr/
    bin/
      omyfendory-launch-browser      # Zen Browser launcher
      omyfendory-launch-webapp       # Webapp mode launcher (minimal UI profile)
      omyfendory-launch-or-focus     # Focus-or-launch helper
      omyfendory-launch-or-focus-webapp # Focus-or-launch for webapps
      omyfendory-power-menu          # Lock/suspend/reboot/shutdown
      omyfendory-screenshot          # Region screenshot pipeline
      omyfendory-toggle-nightlight   # Hyprsunset toggle
      omyfendory-toggle-idle         # Hypridle toggle
      omyfendory-setup-arch-dev      # Distrobox setup script
    lib/systemd/system/
      omyfendory-flatpak-manager.service
    libexec/
      omyfendory-flatpak-manager     # First-boot Flatpak installer
    share/
      applications/
        firmador.desktop             # Firmador PDF signer launcher
      omyfendory/flatpak/
        install                      # Flatpak app list
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

1. **Build time** (`Containerfile` + `build.sh`): installs RPM packages from Fedora repos and COPRs, downloads eza and iA Writer fonts from GitHub, installs Firma Digital middleware from bundled RPMs and Firmador from firmador.libre.cr, configures GDM autologin, enables services, pre-configures Flathub remote.
2. **Image delivery**: CI builds the OCI image daily, pushes to GHCR, signs with [cosign](https://github.com/sigstore/cosign).
3. **First boot**: `omyfendory-flatpak-manager.service` installs all Flatpak apps. A sha256 stamp file ensures it only re-runs when the app list changes. Webapp shortcuts open Zen Browser with a dedicated profile that hides all browser chrome.
4. **Updates**: `bootc upgrade` pulls the latest image atomically. Rollback with `bootc rollback`.

## Verification

Images are signed with cosign. Verify before installing:

```bash
cosign verify --key cosign.pub ghcr.io/luisuma92/omyfendory:latest
```

## Credits

Built on top of [Universal Blue](https://universal-blue.org/) and [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/). Started from the [ublue-os/image-template](https://github.com/ublue-os/image-template).
