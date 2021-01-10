#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

# Gimme some color
NC='\033[0m';RED='\033[0;31m'
function setColor() { echo -ne "${1}"; }

# This script needs to be run as root
if [ "$EUID" -ne 0 ]; then
    setColor "$RED"
    echo "Please run this script as root"
    setColor "$NC"
    exit 1
fi

# Make sure we have a user.yaml file
if [ ! -f "${SCRIPTDIR}/hiera/user.yaml" ]; then
    setColor "$RED"
    echo "Please create hiera/user.yaml file before bootstrapping (use the example as a guide)."
    setColor "$NC"
    exit 1
fi

# Test if puppet is installed and, if not, assume none of the tools are
if ! which puppet &> /dev/null; then
    echo "Installing tools"
    emerge dev-ruby/rubygems
    gem install --no-doc puppet puppet-lint
fi

export RUBYOPT="-W0"

puppet apply "${SCRIPTDIR}/workstation.pp" \
       --modulepath "${SCRIPTDIR}/modules:${SCRIPTDIR}/forge_modules" \
       --hiera_config "${SCRIPTDIR}/hiera/hiera.yaml" \
       "${@}"

