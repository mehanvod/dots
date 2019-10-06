#!/usr/bin/env bash
# Install script for Arch Linux
# autor: Sergey Prostov
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
Home_D="sda3"
Swap_D="sda4"

loadkeys ru
setfont cyr-sun16

timedatectl set-ntp true

## root ##
mkfs.ext4 -L "Arch" /dev/$Root_D
mount /dev/$Root_D /mnt

## boot ##
# mkfs.ext2 /dev/$Boot_D -L boot
mkfs.vfat -F32 -n "Boot" /dev/$Boot_D
mkdir -p /mnt/boot
mount /dev/$Boot_D /mnt/boot

## home ##
mkfs.ext4 -L "Home" /dev/$Home_D
mkdir -p /mnt/home
mount /dev/$Home_D /mnt/home

## swap ##
mkswap -L "Swap" /dev/$Swap_D
swapon /dev/$Swap_D

## Обновление ключей ##
echo "
Данный этап поможет вам избежать проблем с ключами 
Pacmаn, если использкуете не свежий образ ArchLinux для установки! "
echo " Обновим ключи?  "
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " x_key 
    echo ''
    [[ "$x_key" =~ [^10] ]]
do
    :
done
 if [[ $x_key == 1 ]]; then
  clear
  pacman-key --refresh-keys 
  elif [[ $x_key == 0 ]]; then
   echo " Обновление ключей пропущено "   
fi

## Зеркала ##
echo 'Хотите сменить зеркала на более быстрые?'
while 
    read -n1 -p  "
    1 - Максимальная скорость

    2 - Средняя скорость(стабильнее) 
    
    0 - нет: " mirrors # sends right after the keypress
    echo ''
    [[ "$mirrors" =~ [^120] ]]
do
    :
done
if [[ $mirrors == 1 ]]; then
cat > /etc/pacman.d/mirrorlist << EOF
Server = https://mirrors.dotsrc.org/archlinux/\$repo/os/\$arch
Server = https://mirror.osbeck.com/archlinux/\$repo/os/\$arch
Server = https://archlinux.beccacervello.it/archlinux/\$repo/os/\$arch
Server = http://archlinux.mirror.garr.it/archlinux/\$repo/os/\$arch
Server = https://appuals.com/archlinux/\$repo/os/\$arch
Server = https://mirror.checkdomain.de/archlinux/\$repo/os/\$arch
Server = https://mirrors.xtom.nl/archlinux/\$repo/os/\$arch
Server = http://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
EOF
elif [[ $mirrors == 2 ]]; then
cat > /etc/pacman.d/mirrorlist << EOF
Server = https://mirror.yandex.ru/archlinux/\$repo/os/\$arch
Server = http://mirror.aur.rocks/\$repo/os/\$arch
Server = https://mirror.aur.rocks/\$repo/os/\$arch
Server = http://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = http://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch
Server = http://archlinux.zepto.cloud/\$repo/os/\$arch
Server = http://ftp.byfly.by/pub/archlinux/\$repo/os/\$arch
Server = http://mirror.datacenter.by/pub/archlinux/\$repo/os/\$arch
EOF
elif [[ $mirrors == 0 ]]; then
   echo 'смена зеркал пропущена.'   
fi

pacman -Syy

pacstrap /mnt base base-devel linux linux-firmware

cp berb2.sh /mnt/berb2.sh
chmod u+x /mnt/berb2.sh

genfstab -U -p /mnt >> /mnt/etc/fstab

# arch-chroot /mnt sh -c "$(curl -fsSL git.io/berb2.sh)"
arch-chroot /mnt ./berb2.sh
