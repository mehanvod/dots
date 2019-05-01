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

Boot_D="sda1"
Root_D="sda2"
Swap_D="sda3"
Home_D="sda4"

loadkeys ru
setfont cyr-sun16

timedatectl set-ntp true

mkfs.ext4 /dev/$Root_D

# mkfs.ext2 /dev/$Boot_D -L boot
mkfs.fat -F32 /dev/$Boot_D

# mkfs.ext4 /dev/$Home_D -L home
mkswap /dev/$Swap_D -L swap

mount /dev/$Root_D /mnt

# mkdir /mnt/{boot,home}
mkdir -p /mnt/{boot/efi,home}

# mount /dev/$Boot_D /mnt/boot
mount /dev/$Boot_D /mnt/boot/efi

mount /dev/$Home_D /mnt/home
swapon /dev/$Swap_D

# pacman -Sy --noconfirm --needed reflector
# reflector -c "Russia" -c "Denmark" -f 5 -l 5 -p https -n 5 --save /etc/pacman.d/mirrorlist --sort rate

echo "Server = https://mirrors.dotsrc.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "Server = https://mirror.osbeck.com/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

pacman -Sy

pacstrap /mnt base base-devel

cp berb2.sh /mnt/berb2.sh
chmod u+x /mnt/berb2.sh

genfstab -U /mnt >> /mnt/etc/fstab

# arch-chroot /mnt sh -c "$(curl -fsSL git.io/berb2.sh)"
arch-chroot /mnt ./berb2.sh