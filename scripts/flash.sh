#!/bin/bash
set -e

script=`readlink -f ${0}`
script_path=`dirname ${script}`

if [ "${#}" -ne 2 ]; then
	echo "usage: ${script##*/} [device] [files path]"
	exit
fi

device=${1}
files=${2}

if [ -e ${device} ]; then
	echo "device: ${device}"
else
	echo "error: no device (${device})"
	exit
fi

if [ -e ${files} ]; then
	echo "files: ${files}"
else
	echo "error: no files (${files})"
	exit
fi

mounts=`mount | grep ${device}`

if [ "${mounts}" != "" ]; then
	echo "unmount partitions..."
	IFS=$'\n'
	for entry in ${mounts}; do
		dev=`echo ${entry} | cut -d " " -f 1`
		umount -f ${dev}
	done
fi

# Partitions
parted -s ${device} rm 1
parted -s ${device} rm 2

echo "create partitions..."
parted -s ${device} mkpart primary 0 512MB
parted -s ${device} mkpart primary 512MB 100%
parted -s ${device} set 1 boot on
parted -s ${device} set 1 lba on
parted ${device} print

# Filesystem
echo "format partitions..."
mkfs.vfat -F 32 -n boot ${device}1
mkfs.ext4 -F -L root ${device}2

# Mount
mkdir -p /mnt/boot
mkdir -p /mnt/rootfs

mount ${device}1 /mnt/boot
mount ${device}2 /mnt/rootfs

# Copy boot files
echo "copy boot files..."
cp ${files}/boot.bin /mnt/boot/BOOT.BIN
cp ${files}/Image /mnt/boot/
cp ${files}/boot.scr /mnt/boot/

# Extract rootfs
echo "extract rootfs..."
tar xzf ${files}/core-image-minimal-ultra96v2.tar.gz -C /mnt/rootfs/

echo "sync..."
sync

# Unmount
echo "unmount..."
umount /mnt/boot
umount /mnt/rootfs


