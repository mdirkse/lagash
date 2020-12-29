#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source /etc/profile

# Update everything and recompile stuff with modified use flags
emerge -uUDN @world

# 'Read' all of the news
eselect news read --quiet all > /dev/null
eselect news purge > /dev/null

# Clean everything
emerge --depclean
