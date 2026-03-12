# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/silverblue-main:latest

### MODIFICATIONS
## Install packages and configure services via build.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

## Copy system overlay (skel configs, helper scripts)
COPY system_files /

## Install Firma Digital (Costa Rican digital signature)
RUN dnf5 -y install pcsc-lite pcsc-lite-ccid patchelf webkit2gtk4.1 && \
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
    systemctl enable pcscd.socket && \
    rm -rf /opt/FirmaDigital

## Make scripts executable and enable services that depend on copied files
RUN chmod +x /usr/bin/omyfendory-* /usr/libexec/omyfendory-* && \
    systemctl enable omyfendory-flatpak-manager.service && \
    systemctl enable omyfendory-dotfiles-sync.service

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
