#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

# Gimme some color
NC='\033[0m';GREEN='\033[1;32m';LCYAN='\033[1;36m';RED='\033[0;31m';YELLOW='\033[1;33m'

function setColor() { echo -ne "${1}"; }
function prepend() { while read -r line; do echo -e "${2}${1}>${NC} ${line}"; done; }
function zfs_snapshot() {
    SNAPSTAMP=$(date +%k%M%S) 
    zfs snapshot "${ZFS_DS_BOOT}@${1}-${SNAPSTAMP}";
    zfs snapshot "${ZFS_DS_OS}@${1}-${SNAPSTAMP}";
}

# This script needs to be run as root
if [ "$EUID" -ne 0 ]; then
    setColor "$RED"
    echo "Please run this script as root"
    setColor "$NC"
    exit 1
fi

# Make sure we have a user.yaml file
if [ ! -f "${SCRIPTDIR}/../hiera/user.yaml" ]; then
    setColor "$RED"
    echo "Please create hiera/user.yaml file before bootstrapping (use the example as a guide)."
    setColor "$NC"
    exit 1
fi

setColor "$LCYAN"

# Test if puppet is installed and, if not, assume none of the tools are
if which puppet &> /dev/null; then
    echo "Tools are installed"
else 
    echo "Installing tools"
    add-apt-repository -y universe > /dev/null
    apt-get -q update > /dev/null
    apt-get -q -y install jq ntpdate python3-pip ruby shellcheck > /dev/null
    gem install -N puppet puppet-lint > /dev/null
    pip3 install -q yq  > /dev/null
    echo "Setting the time"
    ntpdate -u pool.ntp.org > /dev/null
fi

# Get all the necessary variable from yaml
DISK=$(yq -r .bootstrap.disk "${SCRIPTDIR}/../hiera/bootstrap.yaml")
GENTOO_MNT=$(yq -r .bootstrap.mount "${SCRIPTDIR}/../hiera/bootstrap.yaml")
MAKE_JOBS=$(yq -r .bootstrap.jobs.make "${SCRIPTDIR}/../hiera/bootstrap.yaml")
USERNAME=$(yq -r .user.username "${SCRIPTDIR}/../hiera/user.yaml")

ZPOOL_BOOT=$(yq -r .bootstrap.zpool.boot.name "${SCRIPTDIR}/../hiera/bootstrap.yaml")
ZFS_BOOT_DS=$(yq -r .bootstrap.zpool.boot.ds.boot "${SCRIPTDIR}/../hiera/bootstrap.yaml")

ZPOOL_ROOT=$(yq -r .bootstrap.zpool.root.name "${SCRIPTDIR}/../hiera/bootstrap.yaml")
ZFS_HOME_DS=$(yq -r .bootstrap.zpool.root.ds.home "${SCRIPTDIR}/../hiera/bootstrap.yaml")
ZFS_OS_DS=$(yq -r .bootstrap.zpool.root.ds.os "${SCRIPTDIR}/../hiera/bootstrap.yaml")

# Derive the zfs dataset names
ZFS_DS_BOOT="${ZPOOL_BOOT}/${ZFS_BOOT_DS}"
ZFS_DS_HOME="${ZPOOL_ROOT}/${ZFS_HOME_DS}"
ZFS_DS_OS="${ZPOOL_ROOT}/${ZFS_OS_DS}"

echo "Targeting disk [${DISK}]"

# Check if we need to partiton the drive
# If the 3rd partition (5th line of the output) in the table is called 'zfs' then assume we're good
ZFS_PARTITION_NAME=$(parted -m "${DISK}" print | sed -n 5,5p | cut -d':' -f6)
if [ "${ZFS_PARTITION_NAME}" == "zfs" ]; then 
    echo "Disk properly partitioned."
else
    echo "Partitioning the disk"
    wipefs -qa "${DISK}"
    parted "${DISK}" -a optimal mklabel gpt
    parted "${DISK}" -a optimal mkpart esp "1 513"
    parted "${DISK}" -a optimal set 1 boot on
    parted "${DISK}" -a optimal mkpart boot "513 1537"
    parted "${DISK}" -a optimal mkpart zfs "1537 -1"
    # UEFI requires the ESP partition to be FAT32, so...
    # But we gotta sleep for a second to allow the partition to be recognized
    sleep 1
    mkfs.fat -F32 "${DISK}p1" > /dev/null
fi

# Create the boot zpool if necessary
# Don't use any fancy features by default because GRUB2 doesn't
# support many of them. Turn the supported ones on explicitly.
if zpool status "${ZPOOL_BOOT}" > /dev/null 2>&1; then
    echo "Boot zpool [${ZPOOL_BOOT}] exists"
else
    echo "Creating boot zpool [${ZPOOL_BOOT}]"
    zpool create -df -o ashift=12 \
                     -o autotrim=on \
                     -o cachefile= \
                     -o feature@allocation_classes=enabled \
                     -o feature@async_destroy=enabled      \
                     -o feature@bookmarks=enabled          \
                     -o feature@embedded_data=enabled      \
                     -o feature@empty_bpobj=enabled        \
                     -o feature@enabled_txg=enabled        \
                     -o feature@extensible_dataset=enabled \
                     -o feature@filesystem_limits=enabled  \
                     -o feature@hole_birth=enabled         \
                     -o feature@large_blocks=enabled       \
                     -o feature@lz4_compress=enabled       \
                     -o feature@project_quota=enabled      \
                     -o feature@resilver_defer=enabled     \
                     -o feature@spacemap_histogram=enabled \
                     -o feature@spacemap_v2=enabled        \
                     -o feature@userobj_accounting=enabled \
                     -o feature@zpool_checkpoint=enabled   \
                     -O atime=off \
                     -O xattr=sa \
                     -m none \
                     -R "${GENTOO_MNT}" \
                     "${ZPOOL_BOOT}" \
                     "${DISK}"p2
fi

# Create the root zpool if necessary
if zpool status "${ZPOOL_ROOT}" > /dev/null 2>&1; then
    echo "Root zpool [${ZPOOL_ROOT}] exists"
else
    echo "Creating root zpool [${ZPOOL_ROOT}]"
    zpool create -f -o ashift=12 \
                    -o autotrim=on \
                    -o cachefile= \
                    -O compression=lz4 \
                    -O acltype=posixacl \
                    -O atime=off \
                    -O xattr=sa \
                    -m none \
                    -R "${GENTOO_MNT}" \
                    "${ZPOOL_ROOT}" \
                    "${DISK}"p3
fi

# Create the boot zfs if necessary
if zfs list "${ZFS_DS_BOOT}" > /dev/null 2>&1; then
    echo "Boot zfs dataset [${ZFS_DS_BOOT}] exists"
else
    echo "Creating boot zfs dataset [${ZFS_DS_BOOT}]"
    zfs create -o canmount=noauto \
               -o compression=gzip-9 \
               -o dnodesize=legacy \
               -o mountpoint=/boot \
               "${ZFS_DS_BOOT}"
    zpool set bootfs="${ZFS_DS_BOOT}" "${ZPOOL_BOOT}"
fi

# Create the root zfs if necessary
if zfs list "${ZFS_DS_OS}" > /dev/null 2>&1; then
    echo "OS zfs dataset [${ZFS_DS_OS}] exists"
else
    echo "Creating OS zfs dataset [${ZFS_DS_OS}]"
    zfs create -o canmount=noauto \
               -o compression=lz4 \
               -o mountpoint=/ \
               "${ZFS_DS_OS}"
fi

# Create the home zfs if necessary
if zfs list "${ZFS_DS_HOME}" > /dev/null 2>&1; then
    echo "User home zfs dataset [${ZFS_DS_HOME}] exists"
else
    echo "Creating user home zfs dataset [${ZFS_DS_HOME}] (must enter passphrase)"
    zfs create -o canmount=noauto \
               -o compression=lz4 \
               -o encryption=aes-256-gcm \
               -o keyformat=passphrase \
               -o keylocation=prompt \
               -o "mountpoint=/home/${USERNAME}" \
               "${ZFS_DS_HOME}"
fi

if df | grep "${ZFS_DS_OS}" > /dev/null; then
    echo "OS zfs dataset already mounted"
else
    echo "Mounting OS zfs dataset"
    zfs mount "${ZFS_DS_OS}"
fi

if df | grep "${ZFS_DS_BOOT}" > /dev/null; then
    echo "Boot zfs dataset already mounted"
else
    echo "Mounting boot zfs dataset"
    zfs mount "${ZFS_DS_BOOT}"
fi

if df | grep "${ZFS_DS_HOME}" > /dev/null; then
    echo "Home zfs dataset already mounted"
else
    echo "Mounting boot zfs dataset"
    zfs mount "${ZFS_DS_HOME}"
fi

# Make sure facter is properly configured
mkdir -p /etc/puppetlabs/facter
cp "${SCRIPTDIR}/../modules/base/files/facter.conf" /etc/puppetlabs/facter

zfs_snapshot "empty"

echo "Running puppet"

puppet apply "${SCRIPTDIR}/bootstrap.pp" \
       --modulepath "${SCRIPTDIR}/../modules:${SCRIPTDIR}/../forge_modules" \
       --hiera_config "${SCRIPTDIR}/../hiera/hiera.yaml" \
       "${@}" 2>&1 | prepend "puppet" "$GREEN"

zfs_snapshot "puppet"

setColor "$LCYAN"
echo "Prepping emerge"
chroot "${GENTOO_MNT}" /tmp/bootstrap/prepare-emerge.sh 2>&1 | prepend "emerge" "$YELLOW"
zfs_snapshot "emerge-prepped"

setColor "$LCYAN"
echo "Configuring and installing the kernel"
chroot "${GENTOO_MNT}" /tmp/bootstrap/install-kernel.sh "${MAKE_JOBS}" 2>&1 | prepend "kernel" "$YELLOW"
zfs_snapshot "kernel-installed"

setColor "$LCYAN"
echo "Configuring and installing GRUB"
chroot "${GENTOO_MNT}" /tmp/bootstrap/install-grub.sh 2>&1 | prepend "grub" "$YELLOW"
zfs_snapshot "grub-installed"

setColor "$LCYAN"
echo "Upgrading @world and USE flags"
chroot "${GENTOO_MNT}" /tmp/bootstrap/upgrade-world-and-use.sh 2>&1 | prepend "upgrade" "$YELLOW"
zfs_snapshot "world-use-upgraded"

setColor "$LCYAN"
echo "Installing necessary packages, updating everything and cleaning up"
chroot "${GENTOO_MNT}" /tmp/bootstrap/install-packages.sh 2>&1 | prepend "packages" "$YELLOW"
zfs_snapshot "packages-installed"

setColor "$LCYAN"
echo "Finishing the system config"
chroot "${GENTOO_MNT}" /tmp/bootstrap/finish-config.sh "${USERNAME}" 2>&1 | prepend "config" "$YELLOW"

setColor "$LCYAN"

read -p "Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    zfs_snapshot "installed"
    umount -l /mnt/gentoo/{dev,sys,proc}
    umount -R /mnt/gentoo/boot
    umount -R "/mnt/gentoo/home/${USERNAME}"
    umount -R /mnt/gentoo
    zfs set mountpoint=legacy "${ZFS_DS_BOOT}"
    zfs set mountpoint=/ "${ZFS_DS_OS}"
    zfs set "mountpoint=/home/${USERNAME}" "${ZFS_DS_HOME}"
    echo "Rebooting..."
    reboot
fi

echo "Not rebooting."
exit 0
