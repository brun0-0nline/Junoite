# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM quay.io/fedora/fedora-kinoite:latest

# SYSTEMD
COPY --chmod=0644 ./systemd/snap.mount /etc/systemd/system/snap.mount
COPY --chmod=0644 ./systemd/snap-symlink.service /etc/systemd/system/snap-symlink.service 
COPY --chmod=0644 ./systemd/mkdir-rootfs@.service /etc/systemd/system/mkdir-rootfs@.service
COPY --chmod=0644 ./systemd/home.mount /etc/systemd/system/home.mount

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

### LINTING
RUN bootc container lint