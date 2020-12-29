#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source /etc/profile

# Sync with the interwebz
emerge --sync --quiet

# Set the timezone
emerge --config sys-libs/timezone-data

# Generate and select the appropriate locale
locale-gen
eselect locale set en_US.utf8
