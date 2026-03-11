#!/bin/bash
set -ouex pipefail

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Omyfendory build script
# Layers Hyprland + tools on top of bazzite-gnome:stable
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ─── Enable COPRs ──────────────────────────────────────────────

dnf5 -y install dnf5-plugins || true

# Hyprland ecosystem (uwsm, hyprsunset, satty, etc.)
dnf5 -y copr enable solopasha/hyprland
# SwayOSD (volume/brightness OSD)
dnf5 -y copr enable erikreider/swayosd
# lazygit + lazydocker
dnf5 -y copr enable atim/lazygit
dnf5 -y copr enable atim/lazydocker

# mise (dev tool version manager) — official repo
dnf5 -y config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo

# Fix COPR repo_gpgcheck issue with dnf5 in container builds
sed -i 's/repo_gpgcheck=1/repo_gpgcheck=0/' /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:*.repo

# ─── Hyprland ecosystem ───────────────────────────────────────

dnf5 -y install \
    hyprland \
    hypridle \
    hyprlock \
    hyprpicker \
    hyprsunset \
    hyprland-qtutils \
    hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    uwsm \
    waybar \
    mako \
    swaybg \
    swayosd \
    slurp \
    satty \
    wl-clipboard \
    cliphist \
    brightnessctl \
    playerctl \
    pamixer \
    wofi \
    grim

# ─── Terminal ──────────────────────────────────────────────────

dnf5 -y install foot

# ─── Fonts ─────────────────────────────────────────────────────
# Nerd fonts (CaskaydiaMono, JetBrainsMono) already in bazzite base
# via che/nerd-fonts COPR (nerd-fonts package)

dnf5 -y install fontawesome-fonts-all

# iA Writer fonts (not packaged for Fedora — install from GitHub)
curl -sL -o /tmp/ia-fonts.tar.gz https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.tar.gz
mkdir -p /usr/share/fonts/iA-Writer
tar xzf /tmp/ia-fonts.tar.gz -C /tmp
cp /tmp/iA-Fonts-master/iA\ Writer\ Mono/Static/*.ttf /usr/share/fonts/iA-Writer/
cp /tmp/iA-Fonts-master/iA\ Writer\ Duo/Static/*.ttf /usr/share/fonts/iA-Writer/
cp /tmp/iA-Fonts-master/iA\ Writer\ Quattro/Static/*.ttf /usr/share/fonts/iA-Writer/
fc-cache -fv
rm -rf /tmp/ia-fonts.tar.gz /tmp/iA-Fonts-master

# ─── CLI tools ─────────────────────────────────────────────────

dnf5 -y install \
    neovim \
    tmux \
    zoxide \
    eza \
    fd-find \
    bat \
    du-dust \
    fzf \
    ripgrep \
    starship \
    lazygit \
    lazydocker \
    mise \
    imv \
    zathura \
    zathura-pdf-mupdf

# ─── Disable COPRs ────────────────────────────────────────────
# Prevent COPRs from persisting on the final image

dnf5 -y copr disable solopasha/hyprland
dnf5 -y copr disable erikreider/swayosd
dnf5 -y copr disable atim/lazygit
dnf5 -y copr disable atim/lazydocker
dnf5 -y config-manager setopt mise.enabled=0

# ─── Flatpak remote ──────────────────────────────────────────
# Pre-configure Flathub so the flatpak-manager service can install apps

mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ─── Services ──────────────────────────────────────────────────

systemctl enable podman.socket
systemctl enable omyfendory-flatpak-manager.service

# ─── GDM autologin with Hyprland ──────────────────────────────

mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMCONF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=luis
DefaultSession=hyprland-uwsm.desktop

[security]

[xdmcp]

[chooser]

[debug]
GDMCONF
