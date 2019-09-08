#!/bin/bash -x

ls -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

cp /etc/locale.gen /etc/locale.gen.bak
grep -E "ru_RU|^#en_US" /etc/locale.gen | cut -d"#" -f 2 >> /etc/locale.gen
locale-gen
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo -e "KEYMAP=ru\nFONT=cyr-sun16" > /etc/vconsole.conf

echo "Enter hostname: "
read hostname
echo "$hostname" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$hostname.localdomain\t$hostname" >> /etc/hosts

mkinitcpio -p linux

bootctl --path=/boot install
bootctl update
mkdir /etc/pacman.d/hooks
echo "
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd
[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update" > /etc/pacman.d/hooks/100-systemd-boot.hook

echo "
timeout 0
#console-mode keep
default arch-*
editor 0" > /boot/loader/loader.conf

ROOT_PARTUUID=$(blkid -s PARTUUID -o value /dev/sda2)

echo "
title   Arch Linux
linux   /vmlinuz-linux
initrd	/amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$ROOT_PARTUUID rw" > /boot/loader/entries/arch.conf
ln -s /dev/null /etc/tmpfiles.d/linux-firmware.conf
cd /boot && pacman -S amd-ucode --noconfirm

echo "Введите новый пароль для ROOT"
passwd

exit
