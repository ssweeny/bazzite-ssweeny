#!/bin/bash

set -ouex pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E %fedora)"

### Install packages
wget "https://copr.fedorainfracloud.org/coprs/szydell/system76/repo/fedora-${RELEASE}/szydell-system76-fedora-${RELEASE}.repo" -O /etc/yum.repos.d/szydell-system76-fedora-${RELEASE}.repo
wget "https://copr.fedorainfracloud.org/coprs/ssweeny/system76-hwe/repo/fedora-${RELEASE}/ssweeny-system76-hwe-fedora-${RELEASE}.repo" -O /etc/yum.repos.d/_copr_ssweeny-system76-hwe-fedora-${RELEASE}.repo

# install my custom packages
rpm-ostree install \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-pop-shell \
    gnome-shell-extension-pop-shell-shortcut-overrides \
    system76-firmware \
    system76-power \
    zsh

# Install system76-io modules
rpm-ostree install \
    "akmod-system76-io-*.fc${RELEASE}.${ARCH}"
akmods --force --kernels "${KERNEL}" --kmod system76-io
modinfo "/usr/lib/modules/${KERNEL}/extra/system76-io/system76-io.ko.xz" >/dev/null ||
    (find /var/cache/akmods/system76-io/ -name \*.log -print -exec cat {} \; && exit 1)

# Need system76-power to control the Thelio fan speed
systemctl mask upower.service
systemctl enable com.system76.PowerDaemon.service
