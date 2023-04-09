#!/bin/bash

set -e

source /etc/profile

echo "Running install..."

echo "root:Park_Queue6Ship" | chpasswd > /dev/null

echo "Root password set."

mount /dev/vda1 /boot

cat fstab >> /etc/fstab

# first run of emerge returns an error when it makes a database
emerge 2>&1 > /dev/null || true
emerge-webrsync
emerge --sync

#eselect profile list
#eselect profile set 11
eselect profile set 23

#emerge --verbose --update --deep --newuse @world

emerge sys-kernel/installkernel-gentoo

#emerge sys-kernel/gentoo-kernel
emerge sys-kernel/gentoo-kernel-bin

#systemd-firstboot --prompt --setup-machine-id
systemd-firstboot --setup-machine-id
systemctl preset-all --preset-mode=enable-only
systemctl preset-all

emerge --verbose sys-boot/grub
grub-install /dev/vda

grub-mkconfig -o /boot/grub/grub.cfg
