#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source /etc/profile

# Install a bunch of packages we'll need after the reboot
emerge -uDN app-admin/sudo \
            app-portage/eix \
            dev-vcs/git \
            net-misc/connman \
            net-wireless/wpa_supplicant \
            sys-fs/fuse
