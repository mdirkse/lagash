#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

ROOT="$1"
SCRIPTDIR=$(dirname $(readlink -f "$0"))

nixos-install --flake "${SCRIPTDIR}#vm" --root "$ROOT" --no-root-passwd
