#!/usr/bin/env bash
# Install script for Arch Linux
# autor: Sergey Prostov 
# https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb2.sh
# wget git.io/berb2.sh
# nano berb2.sh

DISK="sda"

sed -i 's/^#Color/Color/g' /etc/pacman.conf
sed -i 's/^#TotalDownload/TotalDownload/g' /etc/pacman.conf
sed -i 's/^#CheckSpace/CheckSpace/g' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
sed -i 's/.*\VerbosePkgLists\.*/&\nILoveCandy/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacman -Syy

pack="xorg-apps xorg-server xorg-xinit \
mesa xf86-video-amdgpu xf86-input-synaptics \
dialog wpa_supplicant iw net-tools linux-headers dkms \
gtk-engines gtk-engine-murrine xdg-user-dirs-gtk qt5-styleplugins qt5ct \
arc-gtk-theme papirus-icon-theme \
ttf-dejavu ttf-font-awesome ttf-fantasque-sans-mono \
alsa-utils gstreamer pulseaudio pulseaudio-alsa \
ffmpeg mpc mpd mpv ncmpcpp streamlink youtube-dl youtube-viewer \
bash-completion gtk2-perl termite xterm wmctrl zsh zsh-syntax-highlighting neovim \
reflector htop scrot imagemagick compton \
openssh pcmanfm samba hddtemp xclip gxkb \
curl wget git rsync python-pip unzip file-roller unrar p7zip \
gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g \
gsimplecal redshift numlockx \
galculator firefox firefox-i18n-ru \
pavucontrol qbittorrent viewnior"

pacman -S --noconfirm --needed $pack

echo "#####################################################################"
echo ""
echo " Установка DE(WM). Выберите пункт для установки "
while 
    read -n1 -p  "
    1 - Awesome(WM)+lightdm
    
    2 - Xfce+lightdm 

    0 - пропустить " x_de
    echo ''
    [[ "$x_de" =~ [^120] ]]
do
    :
done
if [[ $x_de == 0 ]]; then
  echo 'уcтановка DE пропущена' 
elif [[ $x_de == 1 ]]; then
pacman -S awesome lightdm lightdm-gtk-greeter --noconfirm
systemctl enable lightdm
clear
echo "Awesome(WM) успешно установлено"
elif [[ $x_de == 2 ]]; then
pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
systemctl enable lightdm
clear
echo "Xfce успешно установлено"
fi

# Root password
while true; do
    clear
    echo -e "\nКаким должно быть ваше имя компьютера?"

    printf "\n\nHostname: "
    read -r HOST

    printf "Вы выбрали %s для своего компьютера. Хотите продолжить? [y/N]: " "$HOST"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done

echo "Прописываем имя компьютера"
echo $HOST > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1       localhost.localdomain   localhost   $HOST
::1             localhost.localdomain   localhost   $HOST
EOF

# user add & password
while true; do
    clear
    echo -e "\nКаким должно быть ваше имя пользователя?"

    printf "\n\nUsername: "
    read -r USER

    printf "Вы выбрали %s для своего имени. Хотите продолжить? [y/N]: " "$USER"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done

useradd -m -g users -G "adm,audio,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh "$USER"

echo " Укажите пароль для "ROOT" "
passwd

echo 'Добавляем пароль для пользователя '$USER' '
passwd "$USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

usermod -c 'Сергей Простов' $USER

cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOF
[greeter]
background=/usr/share/pixmaps/010.jpg
theme-name=Fantome
icon-theme-name=Papirus
font-name=Roboto 9
xft-antialias=true
xft-dpi=96
xft-hintstyle=true
xft-rgba=rgb
indicators=~clock;~session;~power;
position=5% 40%
EOF

cat > /etc/X11/xorg.conf.d/70-synaptics.conf << EOF
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

cat > /usr/share/X11/xorg.conf.d/10-amdgpu.conf << EOF
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

cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us,ru"
        Option "XkbModel" "pc105"
        Option "XkbVariant" ","
        Option "XkbOptions" "grp:alt_shift_toggle,terminate:ctrl_alt_bksp"
EndSection
EOF

cat > /etc/samba/smb.conf << EOF
[global]
workgroup = WORKGROUP
server string = Sergei  
server role = standalone server
log file = /var/log/samba/%m.log
dns proxy = no 
map to guest = bad password

[Файлы]
path = /home/bear/Public
force user = bear
browseable = yes
guest ok = yes
public = yes
writable = yes

[Фильмы]
path = /home/bear/Videos
force user = bear
browseable = yes
guest ok = yes
public = yes
writable = yes
EOF

sudo systemctl enable smb.service
sudo systemctl enable nmb.service

##Change your username here
read -p "Какой у Ваc логин? Он будет использоваться для добавления этого пользователя в smb : " choice
sudo smbpasswd -a $choice

echo " Настроим localtime "
while 
    read -n1 -p  "
    1 - Москва

    2 - Саратов
    
    3 - Екатеринбург
    
    4-  Новосибирск

    5 - Якутск

    0 - пропустить(если нет вашего варианта) : " wm_time 
    echo ''
    [[ "$wm_time" =~ [^123450] ]]
do
    :
done
if [[ $wm_time == 1 ]]; then
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo " Москва "
elif [[ $wm_time == 2 ]]; then
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime
echo " Саратов "
elif [[ $wm_time == 3 ]]; then  
ln -sf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
echo " Екатеринбург "
elif [[ $wm_time == 4 ]]; then 
ln -sf /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime
echo " Новосибирск "
elif [[ $wm_time == 5 ]]; then
ln -sf /usr/share/zoneinfo/Asia/Yakutsk /etc/localtime
echo " Якутск "
elif [[ $wm_time == 0 ]]; then 
clear
echo  " этап пропущен " 
fi

hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf
sed -i 's/#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=38"/g' /etc/profile.d/freetype2.sh
sed -i 's/MODULES=()/MODULES=(amdgpu)/g' /etc/mkinitcpio.conf
sed -i 's/#SystemMaxUse=/SystemMaxUse=5M/g' /etc/systemd/journald.conf
sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/g' /etc/lightdm/lightdm.conf

mkinitcpio -p linux

# pacman -S --noconfirm --needed grub
pacman -S --noconfirm --needed efibootmgr

# grub-install /dev/$DISK
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force
# grub-mkconfig -o /boot/grub/grub.cfg

bootctl install

cat > /boot/loader/loader.conf << EOF
default arch
timeout 0
editor 1
EOF

cat > /boot/loader/entries/arch.conf << EOF
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda1  rw quiet splash
EOF

echo "##################################################################################"
echo "###################   <<<< установка программ из AUR >>>    ######################"
echo "##################################################################################"
cd /home/$USER
git clone https://aur.archlinux.org/rtlwifi_new-extended-dkms.git
chown -R $USER:users /home/$USER/rtlwifi_new-extended-dkms   
chown -R $USER:users /home/$USER/rtlwifi_new-extended-dkms/PKGBUILD 
cd /home/$USER/rtlwifi_new-extended-dkms
sudo -u $USER  makepkg -si --noconfirm
rm -Rf /home/$USER/rtlwifi_new-extended-dkms

echo "##################################################################################"
echo "###################   <<<< Настройка сети >>>    ######################"
echo "##################################################################################"
TARGET_DEVICE=wlp3s0
read -p "Введите имя WiFi(ESSID): " WIFI_ESSID
read -p "Введите пароль: " WIFI_PASSF

cat > /etc/systemd/network/$TARGET_DEVICE-wireless.network << EOF
[Match]
Name=$TARGET_DEVICE

[Network]
Address=192.168.1.3/24
Gateway=192.168.1.1
DNS=8.8.8.8
EOF

# Если вдруг отсутствует
cat > /etc/systemd/system/wpa_supplicant@$TARGET_DEVICE.service << EOF
[Unit]
Description=WPA supplicant for $TARGET_DEVICE

[Service]
ExecStart=/sbin/wpa_supplicant -i $TARGET_DEVICE -c/etc/wpa_supplicant/wpa_supplicant-$TARGET_DEVICE.conf

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOF
update_config=1
eapol_version=1
ap_scan=1
fast_reauth=1
EOF

# passphrase будет записан в файле, в том числе, открытым текстом!
wpa_passphrase $WIFI_ESSID $WIFI_PASSF >> /etc/wpa_supplicant/wpa_supplicant.conf

chmod go-rwx /etc/wpa_supplicant/wpa_supplicant.conf

ln -s /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant-$TARGET_DEVICE.conf

rm /etc/resolv.conf 
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

systemctl stop wpa_supplicant
systemctl disable wpa_supplicant
systemctl enable wpa_supplicant@$TARGET_DEVICE.service
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable dhcpcd

# Права
chmod a+s /usr/sbin/hddtemp

echo "Настройка Системы Завершена"
