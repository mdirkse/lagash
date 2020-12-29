#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source /etc/profile

# First install and build the kernel and zfs so we can do snapshots
emerge -N sys-kernel/gentoo-sources \
          sys-kernel/genkernel \
          sys-kernel/linux-firmware

# Copy the kernel config. Can't do this in puppet because the destination is
# only created when we install sys-kernel/gentoo-sources
cp /tmp/kernel.config /usr/src/linux/.config

# Get ready to build the kernel
cd /usr/src/linux
make modules_prepare
make "-j${1}"
make modules_install
make install
emerge -uDN sys-fs/zfs sys-fs/zfs-kmod
emerge @module-rebuild

# Generate the initramfs
genkernel initramfs --firmware \
                    --kernel-config=/usr/src/linux/.config \
                    --keymap \
                    --makeopts="-j${1}" \
                    --mountboot \
                    --no-clean \
                    --zfs
