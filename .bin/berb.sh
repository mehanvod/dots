#!/usr/bin/env bash
# Install script for Arch Linux
# autor: Sergey Prostov (taken from Alex Creio https://github.com/creio )
# https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb.sh
# wget git.io/berb.sh 
# nano berb.sh 
# sh berb.sh

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   echo "Try 'sudo sh'"
   echo ""
   exit 1
fi

R_DISK="sda1"
B_DISK="sda2"
H_DISK="sda3"
S_DISK="sda4"

loadkeys ru
setfont cyr-sun16

timedatectl set-ntp true

mkfs.ext4 /dev/$R_DISK

mkfs.ext2 /dev/$B_DISK -L boot
# mkfs.fat -F32 /dev/$B_DISK -L boot

# mkfs.ext4 /dev/$H_DISK -L home
mkswap /dev/$S_DISK -L swap

mount /dev/$R_DISK /mnt

mkdir /mnt/{boot,home}
# mkdir -p /mnt/{boot/efi,home}

mount /dev/$B_DISK /mnt/boot
# mount /dev/$B_DISK /mnt/boot/efi

mount /dev/$H_DISK /mnt/home
swapon /dev/$S_DISK

# pacman -Sy --noconfirm --needed reflector
# reflector -c "Russia" -c "Denmark" -f 5 -l 5 -p https -n 5 --save /etc/pacman.d/mirrorlist --sort rate

echo "Server = https://mirrors.dotsrc.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "Server = https://mirror.osbeck.com/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel

cp berb2.sh /mnt/berb2.sh
chmod u+x /mnt/berb2.sh

genfstab -U /mnt >> /mnt/etc/fstab

# arch-chroot /mnt sh -c "$(curl -fsSL git.io/berb2.sh)"
arch-chroot /mnt ./berb2.sh