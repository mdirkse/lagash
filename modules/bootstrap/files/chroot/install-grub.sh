#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source /etc/profile


# Do the GRUB config and installation
emerge -uDN sys-boot/grub \
            sys-boot/os-prober

grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi \
             --efi-directory=/boot/efi \
             --bootloader-id=Gentoo \
             --recheck \
             --no-floppy
