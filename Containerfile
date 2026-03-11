# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/bazzite-gnome:stable

### MODIFICATIONS
## Install packages and configure services via build.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

## Copy system overlay (skel configs, helper scripts)
COPY system_files /

## Make scripts executable and enable services that depend on copied files
RUN chmod +x /usr/bin/omyfendory-* /usr/libexec/omyfendory-* && \
    systemctl enable omyfendory-flatpak-manager.service

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
