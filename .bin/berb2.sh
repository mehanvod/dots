#!/usr/bin/env bash
# Install script for Arch Linux
# autor: Sergey Prostov (taken from Alex Creio https://github.com/creio )
# https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb2.sh
# wget git.io/berb2.sh
# nano berb2.sh

DISK="sda"

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacman -Sy

# pacman -Sy --noconfirm --needed reflector
# reflector -c "Russia" -c "Denmark" -f 5 -l 5 -p https -n 5 --save /etc/pacman.d/mirrorlist --sort rate

echo "Arch Linux Virtualbox?"
read -p "yes, no: " virtualbox_setting
if [[ $virtualbox_setting == no ]]; then
  virtualbox_install=""
elif [[ $virtualbox_setting == yes ]]; then
  virtualbox_install="virtualbox-guest-modules-arch virtualbox-guest-utils"
fi
echo
pacman -S --noconfirm --needed $virtualbox_install

echo "Server = https://mirrors.dotsrc.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "Server = https://mirror.osbeck.com/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

pacman -Sy

pack="xorg-apps xorg-server xorg-xinit \
mesa xf86-video-amdgpu xf86-input-synaptics \
dialog wpa_supplicant iw net-tools linux-headers dkms \
gtk-engines gtk-engine-murrine xdg-user-dirs-gtk qt5-styleplugins qt5ct \
arc-gtk-theme papirus-icon-theme \
ttf-dejavu ttf-font-awesome \
alsa-utils gstreamer pulseaudio pulseaudio-alsa \
ffmpeg mpc mpd mpv ncmpcpp streamlink youtube-dl youtube-viewer \
bash-completion gtk2-perl termite xterm wmctrl zsh zsh-syntax-highlighting \
reflector htop scrot imagemagick compton \
openssh pcmanfm samba gxkb hddtemp xclip \
curl wget git rsync python-pip unzip file-roller unrar p7zip \
gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g \
gsimplecal redshift numlockx \
galculator firefox firefox-i18n-ru \
pavucontrol qbittorrent viewnior \
awesome lightdm lightdm-gtk-greeter"

pacman -S --noconfirm --needed $pack

# Root password
passwd

# user add & password
while true; do
    clear
    echo -e "\nWhat would you like your username to be?
    \n\nDo NOT pick the name of an already existing user. This will overwrite their files!"

    printf "\n\nUsername: "
    read -r USER

    printf "You chose %s for your name. Wanna continue? [y/N]: " "$USER"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done

useradd -m -g users -G "adm,audio,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh "$USER"
passwd "$USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "bear" > /etc/hostname

ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

mkinitcpio -p linux

# pacman -S --noconfirm --needed grub
pacman -S --noconfirm --needed efibootmgr

# grub-install /dev/$DISK
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force
# grub-mkconfig -o /boot/grub/grub.cfg

bootctl install

cat <<EOF > /boot/loader/loader.conf
default arch
timeout 0
editor 1
EOF

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda1  rw quiet splash
EOF

cat <<EOF > /etc/X11/xorg.conf.d/70-synaptics.conf
Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
        Option "TapButton1" "1"
        Option "TapButton2" "3"
        Option "TapButton3" "2"
        Option "VertEdgeScroll" "on"
        Option "VertTwoFingerScroll" "on"
        Option "HorizEdgeScroll" "off"
        Option "HorizTwoFingerScroll" "off"
        Option "CircularScrolling" "off"        
EndSection
EOF

cat <<EOF > /usr/share/X11/xorg.conf.d/10-amdgpu.conf
Section "OutputClass"
    Identifier "AMDgpu"
    MatchDriver "amdgpu"
    Driver "amdgpu"
    Option "DRI" "3"
    Option "TearFree" "true"
    Option "VariableRefresh" "true"
    Option "ShadowPrimary" "true"
    Option "AccelMethod" "string"
EndSection
EOF

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
sed -i 's/#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=38"/g' /etc/profile.d/freetype2.sh

# systemctl enable NetworkManager
systemctl enable lightdm netctl dhcpcd

echo "System Setup Complete"
