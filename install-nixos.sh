#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

ROOT="$1"
SCRIPTDIR=$(dirname $(readlink -f "$0"))

nixos-generate-config --no-filesystems --root "$ROOT"
rm "${ROOT}/etc/nixos/configuration.nix"

cp "${ROOT}/etc/nixos/hardware-configuration.nix" "$SCRIPTDIR"
git -C "$SCRIPTDIR" add hardware-configuration.nix
git -C "$SCRIPTDIR" commit -m"Update hardware-config.nix"

nixos-install --flake "${SCRIPTDIR}#lagash-nixos" --root "$ROOT"
