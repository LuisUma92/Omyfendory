#!/bin/bash
set -ouex pipefail

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Omyfendory build script
# Layers Hyprland + tools on top of silverblue-main:stable
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ─── Enable COPRs ──────────────────────────────────────────────

dnf5 -y install dnf5-plugins || true

# Hyprland ecosystem (uwsm, hyprsunset, satty, etc.)
dnf5 -y copr enable solopasha/hyprland
# SwayOSD (volume/brightness OSD)
dnf5 -y copr enable erikreider/swayosd
# starship prompt
dnf5 -y copr enable atim/starship
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

dnf5 -y copr enable che/nerd-fonts
sed -i 's/repo_gpgcheck=1/repo_gpgcheck=0/' /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:che-nerd-fonts*.repo 2>/dev/null || true
dnf5 -y install nerd-fonts
dnf5 -y copr disable che/nerd-fonts

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
    btop \
    distrobox \
    zoxide \
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

# eza (removed from Fedora repos — install from GitHub release)
EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
curl -sL -o /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
tar xzf /tmp/eza.tar.gz -C /usr/bin
chmod +x /usr/bin/eza
rm -f /tmp/eza.tar.gz

# ─── Firmador (PDF digital signer) ────────────────────────────
# Costa Rican digital signature tool — requires Java 21

dnf5 -y install java-21-openjdk

FIRMADOR_SHA256="cc49f852cdf6a37a35ae25ddc3db90311495b538ff83d334312a00e507de7ef4"

mkdir -p /usr/share/firmador
curl --retry 3 -Lo /usr/share/firmador/firmador.jar \
    https://firmador.libre.cr/firmador.jar
echo "${FIRMADOR_SHA256}  /usr/share/firmador/firmador.jar" | sha256sum -c -

# ─── Disable COPRs ────────────────────────────────────────────
# Prevent COPRs from persisting on the final image

dnf5 -y copr disable solopasha/hyprland
dnf5 -y copr disable erikreider/swayosd
dnf5 -y copr disable atim/starship
dnf5 -y copr disable atim/lazygit
dnf5 -y copr disable atim/lazydocker
rm -f /etc/yum.repos.d/mise.repo

# ─── Flatpak remote ──────────────────────────────────────────
# Pre-configure Flathub so the flatpak-manager service can install apps

mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ─── Services ──────────────────────────────────────────────────

systemctl enable podman.socket

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
