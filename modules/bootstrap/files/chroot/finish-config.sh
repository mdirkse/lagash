#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source /etc/profile

# Set the machine id
systemd-firstboot --setup-machine-id

# Enable all ZFS related systemd stuff
systemctl enable zfs-import-cache \
                 zfs-import.target \
                 zfs-import-scan \
                 zfs-mount \
                 zfs.target \
                 zfs-import-bpool.service \
                 zfs-import-home.service

# Do a bunch of setup that's easier to do here than in puppet
ln -sf /proc/self/mounts /etc/mtab

echo "Set the root password:"
passwd

useradd -m -G audio,cdrom,portage,usb,users,video,wheel -s /bin/bash "${1}"
echo "Set the password for user [${1}]:"
passwd "${1}"
