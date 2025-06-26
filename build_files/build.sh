#!/bin/bash

set -ouex pipefail

# Install dnf5 if not installed
if ! rpm -q dnf5 >/dev/null; then
    rpm-ostree install dnf5
fi

### Remove packages
dnf5 -y remove firefox \
               firefox-langpacks \
               filelight \
               kjournald \
               kjournald-libs \
               kfind \
               khelpcenter \
               krfb \
               krfb-libs \
               kcharselect \
               kwrite \
               plasma-discover-rpm-ostree

### Post removal cleanup
dnf5 clean all

### Install DNF5 plugins to get the config-manager
dnf5 -y in dnf5-plugins

# Add rpmfusion
dnf5 -y in distribution-gpg-keys && \
rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora) && \
rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-fedora-$(rpm -E %fedora) && \
dnf5 -y --setopt=localpkg_gpgcheck=1 in https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
										https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

### Install packages for codecs and hardware acceleration
dnf5 -y swap ffmpeg-free ffmpeg --allowerasing
dnf5 -y in libva-intel-driver

# Installs snapd and create symlink to make it work (hopefully)
dnf5 -y in snapd
ln -s /var/lib/snapd/snap /snap

# Install distrobox and packages required by homebrew
dnf5 -y in distrobox @development-tools \
                     procps-ng \
                     curl \
                     file

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
