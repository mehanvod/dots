#!/usr/bin/env bash
# Install script for Arch Linux (UEFI)
# autor: Sergey Prostov
# https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb.sh
# wget git.io/berb.sh
# curl -OL git.io/berb.sh

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   echo "Try 'sudo sh'"
   echo ""
   exit 1
fi

Boot_D="sdb1"
Root_D="sdb2"
# Swap_D="sdb3"
Home_D="sdb3"

loadkeys ru
setfont cyr-sun16

## Обновление ключей ##
echo "
Данный этап поможет вам избежать проблем с ключами
Pacmаn, если используете не свежий образ ArchLinux для установки! "
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
## Finland
Server = http://arch.mirror.far.fi/\$repo/os/\$arch
## Russia
Server = https://mirror.yandex.ru/archlinux/\$repo/os/\$arch
Server = http://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = http://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch
Server = http://archlinux.zepto.cloud/\$repo/os/\$arch
## Belarus
Server = http://ftp.byfly.by/pub/archlinux/\$repo/os/\$arch
Server = http://mirror.datacenter.by/pub/archlinux/\$repo/os/\$arch
## Denmark
Server = https://mirrors.dotsrc.org/archlinux/\$repo/os/\$arch
## Czechia
#Server = http://mirror.dkm.cz/archlinux/\$repo/os/\$arch
EOF
elif [[ $mirrors == 0 ]]; then
   echo 'смена зеркал пропущена.'
fi

pacman -Sy --noconfirm

echo ""
lsblk -f
echo " Здесь вы можете удалить boot от старой системы, файлы Windows загрузчика не затрагиваются."
echo " если вам необходимо полность очистить boot раздел, то пропустите этот этап далее установка предложит отформатировать boot раздел "
echo " При установке дуал бут раздел не нужно форматировать!!! "
echo ""
echo 'удалим старый загрузчик linux'
while
    read -n1 -p  "
    1 - удалим старый загрузчкик линукс

    0 -(пропустить) - данный этап можно пропустить если установка производиться первый раз или несколько OS  " boots
    echo ''
    [[ "$boots" =~ [^10] ]]
do
    :
done
if [[ $boots == 1 ]]; then
  clear
 lsblk -f
  echo ""
read -p "Укажите boot раздел (sdb1/sdb1 ( например sdb1 )):" bootd
mount /dev/$bootd /mnt
cd /mnt
ls | grep -v EFI | xargs rm -rfv
cd /mnt/EFI
ls | grep -v Boot | grep -v Microsoft | xargs rm -rfv
cd /root
umount /mnt
  elif [[ $boots == 0 ]]; then
   echo " очистка boot раздела пропущена, далее вы сможете его отформатировать! "
fi
clear
## root ##
mkfs.ext4 -L "Arch" /dev/$Root_D
mount /dev/$Root_D /mnt

## boot ##
# mkfs.ext2 /dev/$Boot_D -L boot
# mkfs.vfat -F32 -n "Boot" /dev/$Boot_D
mkdir -p /mnt/boot
mount /dev/$Boot_D /mnt/boot

## swap ##
# mkswap -L "Swap" /dev/$Swap_D
# swapon /dev/$Swap_D

## home ##
mkfs.ext4 -L "Home" /dev/$Home_D
mkdir -p /mnt/home
mount /dev/$Home_D /mnt/home

# kernel
while [[ $kernel != "1" ]] && [[ $kernel != "2" ]] && [[ $kernel != "3" ]] && [[ $kernel != "4" ]]; do
    echo "####################"
    echo "Какое ядро установить:"
    echo "1) linux           - Ядро Linux"
    echo "2) linux-lts       - Ядро LTS Linux"
    echo "3) linux-zen       - Ядро Zen Linux"
    echo "4) linux-hardened  - Ядро Linux, ориентированное на безопасность"
    echo "####################"
    read -n1 -p">" kernel
done
echo; echo
if [[ $kernel == "1" ]]; then
    kernel="linux"
elif [[ $kernel == "2" ]]; then
    kernel="linux-lts"
elif [[ $kernel == "3" ]]; then
    kernel="linux-zen"
elif [[ $kernel == "4" ]]; then
    kernel="linux-hardened"
else
    kernel=""
fi

# microcode
while [[ $microcode != "1" ]] && [[ $microcode != "2" ]] && [[ $microcode != "3" ]]; do
    echo "####################"
    echo "Install what microcode:"
    echo "1) amd-ucode  - Microcode AMD"
    echo "2) intel-ucode  - Microcode Intel"
    echo "3) not install microcode"
    echo "####################"
    read -n1 -p">" microcode
done
echo; echo
if [[ $microcode == "1" ]]; then
    microcode="amd-ucode"
elif [[ $microcode == "2" ]]; then
    microcode="intel-ucode"
else
    microcode=""
fi

packages="base base-devel $kernel linux-firmware $microcode"
pacstrap /mnt $packages

# cp berb2.sh /mnt/berb2.sh
# chmod u+x /mnt/berb2.sh

genfstab -U /mnt >> /mnt/etc/fstab

# arch-chroot /mnt sh -c "$(curl -fsSL git.io/berb2.sh)"
# arch-chroot /mnt ./berb2.sh


###############################
clear
echo "Если вы производите установку используя Wifi тогда рекомендую  "1" "
echo ""
echo "если проводной интернет тогда "2" "
echo ""
echo 'wifi или dhcpcd ?'
while
    read -n1 -p  "1 - wifi, 2 - dhcpcd: " int # sends right after the keypress
    echo ''
    [[ "$int" =~ [^12] ]]
do
    :
done
if [[ $int == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb2.sh
  mv berb2.sh /mnt
  chmod +x /mnt/berb2.sh
  echo 'первый этап готов '
  echo 'ARCH-LINUX chroot'
  echo '1. проверь  интернет для продолжения установки в черуте || 2.команда для запуска ./berb2.sh или sh berb2.sh'
  arch-chroot /mnt
echo "################################################################"
echo "###################    T H E   E N D      ######################"
echo "################################################################"
umount -a
reboot
  elif [[ $int == 2 ]]; then
  arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb2.sh)"
echo "################################################################"
echo "###################    T H E   E N D      ######################"
echo "################################################################"
umount -a
reboot
fi
