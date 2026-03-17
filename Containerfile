# Base Image
FROM ghcr.io/ublue-os/silverblue-main:latest

### MODIFICATIONS

## Layer 1: Repository setup — COPRs, external repos, gpgcheck fix
RUN --mount=type=cache,dst=/var/cache \
    dnf5 -y install dnf5-plugins || true && \
    dnf5 -y copr enable solopasha/hyprland && \
    dnf5 -y copr enable erikreider/swayosd && \
    dnf5 -y copr enable atim/starship && \
    dnf5 -y copr enable atim/lazygit && \
    dnf5 -y copr enable atim/lazydocker && \
    dnf5 -y copr enable che/nerd-fonts && \
    dnf5 -y config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
    dnf5 -y install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true && \
    sed -i 's/repo_gpgcheck=1/repo_gpgcheck=0/' /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:*.repo

## Layer 2: Hyprland ecosystem
RUN --mount=type=cache,dst=/var/cache \
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

## Layer 3: Terminal + fonts
RUN --mount=type=cache,dst=/var/cache \
    dnf5 -y install \
        foot \
        nerd-fonts \
        fontawesome-fonts-all \
        twitter-twemoji-fonts \
        lato-fonts \
        fira-code-fonts && \
    curl -sL -o /tmp/ia-fonts.tar.gz \
        https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.tar.gz && \
    tar xzf /tmp/ia-fonts.tar.gz -C /tmp && \
    mkdir -p /usr/share/fonts/iA-Writer && \
    cp /tmp/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf /usr/share/fonts/iA-Writer/ && \
    cp /tmp/iA-Fonts-master/iA\ Writer\ Duo/Static/iAWriterDuoS-*.ttf /usr/share/fonts/iA-Writer/ && \
    cp /tmp/iA-Fonts-master/iA\ Writer\ Quattro/Static/iAWriterQuattroS-*.ttf /usr/share/fonts/iA-Writer/ && \
    fc-cache -f /usr/share/fonts/iA-Writer && \
    rm -rf /tmp/ia-fonts.tar.gz /tmp/iA-Fonts-master

## Layer 4: CLI tools + Firmador
RUN --mount=type=cache,dst=/var/cache \
    dnf5 -y install \
        neovim \
        tmux \
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
        zathura-pdf-mupdf \
        java-21-openjdk && \
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -sL -o /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" && \
    tar xzf /tmp/eza.tar.gz -C /usr/bin && \
    chmod +x /usr/bin/eza && \
    rm -f /tmp/eza.tar.gz && \
    mkdir -p /usr/share/firmador && \
    curl --retry 3 -Lo /usr/share/firmador/firmador.jar \
        https://firmador.libre.cr/firmador.jar && \
    echo "cc49f852cdf6a37a35ae25ddc3db90311495b538ff83d334312a00e507de7ef4  /usr/share/firmador/firmador.jar" | sha256sum -c -

## Layer 5: System packages — hardware, audio, archive, btrfs, network, utilities
RUN --mount=type=cache,dst=/var/cache \
    dnf5 -y install --allowerasing \
        ddcutil \
        i2c-tools \
        lm_sensors \
        iio-sensor-proxy \
        input-remapper \
        libinput-utils \
        pulseaudio-utils \
        libfreeaptx \
        ladspa-caps-plugins \
        pipewire-module-filter-chain-sofa \
        p7zip \
        p7zip-plugins \
        rar \
        lzip \
        libaacs \
        libbdplus \
        libbluray \
        libbluray-utils \
        snapper \
        btrfs-assistant \
        compsize \
        waydroid \
        cage \
        wlr-randr \
        tailscale \
        btop \
        fastfetch \
        glow \
        gum \
        duf \
        lshw \
        greenboot \
        greenboot-default-health-checks \
        udica \
        libxcrypt-compat \
        ydotool \
        yad \
        v4l-utils && \
    if [ -f /usr/lib/waydroid/data/scripts/waydroid-net.sh ]; then \
        sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' \
            /usr/lib/waydroid/data/scripts/waydroid-net.sh; \
    fi && \
    if [ -f /usr/bin/btrfs-assistant-launcher ]; then \
        sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' \
            /usr/bin/btrfs-assistant-launcher; \
    fi

## Layer 6: Gaming — Steam, winetricks, mangohud
RUN --mount=type=cache,dst=/var/cache \
    dnf5 -y install \
        steam \
        mangohud && \
    curl --retry 3 -Lo /usr/bin/winetricks \
        https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/bin/winetricks

## Layer 7: Remove unneeded packages + mask unused services
RUN dnf5 -y remove \
        firefox \
        firefox-langpacks \
        toolbox \
        gnome-software \
        gnome-classic-session \
        gnome-tour \
        gnome-extensions-app \
        gnome-system-monitor \
        gnome-initial-setup \
        gnome-shell-extension-background-logo \
        gnome-shell-extension-apps-menu \
        gnome-shell-extension-launch-new-instance \
        gnome-shell-extension-places-menu \
        gnome-shell-extension-window-list || true && \
    systemctl mask iscsi && \
    systemctl mask wpa_supplicant.service

## Layer 8: Disable repositories
RUN dnf5 -y copr disable solopasha/hyprland || true && \
    dnf5 -y copr disable erikreider/swayosd || true && \
    dnf5 -y copr disable atim/starship || true && \
    dnf5 -y copr disable atim/lazygit || true && \
    dnf5 -y copr disable atim/lazydocker || true && \
    dnf5 -y copr disable che/nerd-fonts || true && \
    rm -f /etc/yum.repos.d/mise*.repo && \
    rm -f /etc/yum.repos.d/tailscale*.repo && \
    rm -f /etc/yum.repos.d/fedora-rar*.repo && \
    rm -f /etc/yum.repos.d/rpmfusion-*.repo

## Layer 9: Flathub remote + GDM autologin
RUN mkdir -p /etc/flatpak/remotes.d && \
    curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo \
        https://dl.flathub.org/repo/flathub.flatpakrepo && \
    mkdir -p /etc/gdm && \
    printf '[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=luis\nDefaultSession=hyprland-uwsm.desktop\n\n[security]\n\n[xdmcp]\n\n[chooser]\n\n[debug]\n' > /etc/gdm/custom.conf

## Copy system overlay (skel configs, helper scripts, Firma Digital RPMs)
COPY system_files /

## Layer 10: Firma Digital (Costa Rican digital signature)
RUN --mount=type=cache,dst=/var/cache \
    dnf5 -y install pcsc-lite pcsc-lite-ccid patchelf webkit2gtk4.1 && \
    rpm -i --nodeps /opt/FirmaDigital/Idopte/*.rpm && \
    rpm -i --nodeps /opt/FirmaDigital/Agente\ GAUDI/*.rpm && \
    patchelf --replace-needed libwebkit2gtk-4.0.so.37 libwebkit2gtk-4.1.so.0 \
        /usr/lib/SCMiddleware/SCManager || true && \
    cp /opt/FirmaDigital/Librería/libASEP11.so /usr/lib64/ && \
    cp /opt/FirmaDigital/Librería/libaseLaserP11.so /usr/lib64/ && \
    mkdir -p /usr/lib/x64-athena && \
    ln -sf /usr/lib64/libASEP11.so /usr/lib/x64-athena/libASEP11.so && \
    ln -sf /usr/lib64/libASEP11.so /usr/lib/libASEP11.so && \
    mkdir -p /usr/share/p11-kit/modules && \
    echo "module: /usr/lib/SCMiddleware/libidop11.so" > /usr/share/p11-kit/modules/firma-digital.module && \
    rm -rf /opt/FirmaDigital

## Layer 11: Finalize — make scripts executable, enable all services
RUN chmod +x /usr/bin/omyfendory-* /usr/libexec/omyfendory-* && \
    systemctl enable pcscd.socket && \
    systemctl enable podman.socket && \
    systemctl enable omyfendory-flatpak-manager.service && \
    systemctl enable omyfendory-dotfiles-sync.service

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
