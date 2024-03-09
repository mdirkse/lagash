#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

run_disko () {
  sudo nix --experimental-features \
     "nix-command flakes" \
     run github:nix-community/disko -- \
     --mode disko ./nixos/disko-config.nix
}


while true; do
    read -p "Are you sure you want to format your disk? " yn
    case $yn in
        [Yy]* ) run_disko; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
