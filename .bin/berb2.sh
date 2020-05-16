#!/usr/bin/env bash
# Install script for Arch Linux (UEFI)
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

# graphics driver
amd=$(lspci | grep -e VGA -e 3D | grep 'AMD' 2> /dev/null || echo '')
nvidia=$(lspci | grep -e VGA -e 3D | grep 'NVIDIA' 2> /dev/null || echo '')
intel=$(lspci | grep -e VGA -e 3D | grep 'Intel' 2> /dev/null || echo '')
if [[ -n "$nvidia" ]]; then
  pacman -S --noconfirm nvidia
fi

if [[ -n "$amd" ]]; then
  pacman -S --noconfirm xf86-video-amdgpu
fi

if [[ -n "$intel" ]]; then
  pacman -S --noconfirm xf86-video-intel
fi

if [[ -n "$nvidia" && -n "$intel" ]]; then
  pacman -S --noconfirm bumblebee
  gpasswd -a $username bumblebee
  systemctl enable bumblebeed
fi

echo "#####################################################################"
echo ""
echo " Установка DE(WM). Выберите пункт для установки "
while 
    read -n1 -p  "
    1 - Awesome(WM)+lightdm
    
    2 - Xfce+lightdm 

    3 - KDE(Plasma)

    0 - пропустить " x_de
    echo ''
    [[ "$x_de" =~ [^1230] ]]
do
    :
done
if [[ $x_de == 0 ]]; then
  echo 'уcтановка DE пропущена' 

elif [[ $x_de == 1 ]]; then
pack="xorg-apps xorg-server xorg-xinit xf86-input-synaptics \
awesome lightdm lightdm-gtk-greeter \
linux-headers dkms nano man-db dhcpcd \
dialog wpa_supplicant netctl iw net-tools wmctrl \
gtk-engines gtk-engine-murrine xdg-user-dirs-gtk qt5-styleplugins qt5ct picom \
gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g \
alsa-utils gstreamer pulseaudio pulseaudio-alsa pavucontrol \
bash-completion gtk2-perl termite zsh zsh-syntax-highlighting neovim \
openssh pcmanfm gxkb unclutter papirus-icon-theme \
curl wget git rsync python-pip unzip file-roller unrar p7zip \
gsimplecal redshift numlockx firefox firefox-i18n-ru \
ttf-dejavu ttf-liberation ttf-font-awesome awesome-terminal-fonts \
otf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono"
pacman -S --noconfirm --needed $pack
systemctl enable lightdm

mkdir /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/systemd-boot.hook << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOF
[greeter]
background=/usr/share/pixmaps/009.jpg
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

sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/g' /etc/lightdm/lightdm.conf

cat > /etc/X11/xorg.conf.d/70-synaptics.conf << EOF
Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
        Option "TapButton1" "1"
        Option "TapButton2" "3"
        Option "TapButton3" "2"
        Option "VertEdgeScroll" "1"
        Option "VertTwoFingerScroll" "1"
        Option "HorizEdgeScroll" "0"
        Option "HorizTwoFingerScroll" "0"        
EndSection

Section "InputClass"
        Identifier "touchpad ignore duplicates"
        MatchIsTouchpad "on"
        MatchOS "Linux"
        MatchDevicePath "/dev/input/mouse*"
        Option "Ignore" "on"
EndSection

Section "InputClass"
        Identifier "Default clickpad buttons"
        MatchDriver "synaptics"
        Option "SoftButtonAreas" "50% 0 82% 0 0 0 0 0"
        Option "SecondarySoftButtonAreas" "58% 0 0 15% 42% 58% 0 15%"
EndSection

Section "InputClass"
        Identifier "Disable clickpad buttons on Apple touchpads"
        MatchProduct "Apple|bcm5974"
        MatchDriver "synaptics"
        Option "SoftButtonAreas" "0 0 0 0 0 0 0 0"
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

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf
sed -i 's/#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=38"/g' /etc/profile.d/freetype2.sh

echo "Awesome(WM) успешно установлено"

elif [[ $x_de == 2 ]]; then
pack="xorg-apps xorg-server xorg-xinit xf86-input-synaptics \
xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
linux-headers dkms nano man-db dhcpcd gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g \
gtk-engines gtk-engine-murrine xdg-user-dirs-gtk qt5-styleplugins qt5ct picom \
alsa-utils gstreamer pulseaudio pulseaudio-alsa pavucontrol \
bash-completion gtk2-perl termite zsh zsh-syntax-highlighting neovim \
openssh papirus-icon-theme dialog wpa_supplicant iw net-tools wmctrl \
openssh networkmanager networkmanager-openconnect networkmanager-openvpn \
networkmanager-pptp networkmanager-vpnc network-manager-applet \
curl wget git rsync python-pip unzip file-roller unrar p7zip \
gsimplecal redshift numlockx firefox firefox-i18n-ru \
ttf-dejavu ttf-liberation ttf-font-awesome awesome-terminal-fonts \
otf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono"
pacman -S --noconfirm --needed $pack
systemctl enable lightdm NetworkManager

mkdir /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/systemd-boot.hook << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOF
[greeter]
background=/usr/share/pixmaps/013.jpg
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

sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/g' /etc/lightdm/lightdm.conf

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

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf
sed -i 's/#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=38"/g' /etc/profile.d/freetype2.sh

echo "Xfce успешно установлено"

elif [[ $x_de == 3 ]]; then
pack="xorg-apps xorg-server xorg-xinit xf86-input-synaptics \
plasma-meta kdebase latte-dock sddm sddm-kcm \
linux-headers dkms nano man-db dhcpcd \
dialog wpa_supplicant iw net-tools \
gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g \
alsa-utils gstreamer pulseaudio pulseaudio-alsa pavucontrol \
bash-completion termite zsh zsh-syntax-highlighting neovim \
openssh networkmanager networkmanager-openconnect networkmanager-openvpn \
networkmanager-pptp networkmanager-vpnc network-manager-applet \
curl wget git rsync python-pip unzip unrar p7zip \
numlockx firefox firefox-i18n-ru \
ttf-dejavu ttf-liberation ttf-font-awesome awesome-terminal-fonts \
otf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono"
pacman -S --noconfirm --needed $pack
systemctl enable sddm.service -f
systemctl enable NetworkManager
echo "Plasma успешно установлено"
fi

# Root password
while true; do
    echo -e "\nКаким должно быть ваше имя компьютера?"

    printf "\n\nHostname: "
    read -r HOST

    printf "Вы выбрали %s для своего компьютера. Хотите продолжить? [y/N]: " "$HOST"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done

echo " Укажите пароль для "ROOT" "
passwd

echo "Прописываем имя компьютера"
echo $HOST > /etc/hostname

cat > /etc/hosts << EOF
#
# /etc/hosts: static lookup table for host names
#
#<ip-address>   <hostname.domain.org>   <hostname>
127.0.0.1       localhost.localdomain   localhost   $HOST
::1             localhost.localdomain   localhost   $HOST
# End of file
EOF

# user add & password
while true; do
    echo -e "\nКаким должно быть ваше имя пользователя?"

    printf "\n\nUsername: "
    read -r USER

    printf "Вы выбрали %s для своего имени. Хотите продолжить? [y/N]: " "$USER"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done

useradd -m -g users -G wheel -s /bin/zsh $USER

echo 'Добавляем пароль для пользователя '$USER' '
passwd "$USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

usermod -c 'Сергей Простов' $USER

echo " Настроим localtime "
while 
    read -n1 -p  "
    1 - Москва
    
    2 - Екатеринбург
    
    3 - Новосибирск

    0 - пропустить(если нет вашего варианта) : " wm_time 
    echo ''
    [[ "$wm_time" =~ [^1230] ]]
do
    :
done
if [[ $wm_time == 1 ]]; then
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo " Москва "
elif [[ $wm_time == 2 ]]; then  
ln -sf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
echo " Екатеринбург "
elif [[ $wm_time == 3 ]]; then 
ln -sf /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime
echo " Новосибирск "
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

sed -i 's/MODULES=()/MODULES=(amdgpu)/g' /etc/mkinitcpio.conf
sed -i 's/#SystemMaxUse=/SystemMaxUse=5M/g' /etc/systemd/journald.conf

mkinitcpio -p linux

# pacman -S --noconfirm --needed grub
# grub-install /dev/$DISK
# grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm --needed efibootmgr
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force

# Install amd-ucode for AMD CPU
is_amd_cpu=$(lscpu | grep 'AMD' &> /dev/null && echo 'yes' || echo '')
if [[ -n "$is_amd_cpu" ]]; then
  pacman -S --noconfirm amd-ucode
fi

# Bootloader
# Use system-boot for EFI mode, and grub for others
if [[ -d "/sys/firmware/efi/efivars" ]]; then
  bootctl install

  cat <<EOF > /boot/loader/entries/arch.conf
    title    Arch Linux
    linux    /vmlinuz-linux
    initrd   /amd-ucode.img
    initrd   /initramfs-linux.img
    options  root=/dev/sda2 rw
    options  quiet splash acpi_rev_override=1
EOF

  cat <<EOF > /boot/loader/loader.conf
    default arch
    timeout 0
    editor 1
EOF

  if [[ -z "$is_amd_cpu" ]]; then
    sed -i '/amd-ucode/d' /boot/loader/entries/arch.conf
  fi

  # remove leading spaces
  sed -i 's#^ \+##g' /boot/loader/entries/arch.conf
  sed -i 's#^ \+##g' /boot/loader/loader.conf

  # modify root partion in loader conf
  root_partition=$(mount  | grep 'on / ' | cut -d' ' -f1)
  root_partition=$(df / | tail -1 | cut -d' ' -f1)
  sed -i "s#/dev/sda2#$root_partition#" /boot/loader/entries/arch.conf
else
  disk=$(df / | tail -1 | cut -d' ' -f1 | sed 's#[0-9]\+##g')
  pacman --noconfirm -S grub os-prober
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force "$disk"
  grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "########################################################################################"
echo "###################    <<< установка шрифта для терминала  >>>    ######################"
echo "########################################################################################"
cd /home/$USER
git clone https://aur.archlinux.org/nerd-fonts-jetbrains-mono.git
chown -R $USER:users /home/$USER/nerd-fonts-jetbrains-mono   
chown -R $USER:users /home/$USER/nerd-fonts-jetbrains-mono/PKGBUILD 
cd /home/$USER/nerd-fonts-jetbrains-mono
sudo -u $USER  makepkg -si --noconfirm
rm -Rf /home/$USER/nerd-fonts-jetbrains-mono

echo "########################################################################################"
echo "###################    <<< установка шрифта для терминала  >>>    ######################"
echo "########################################################################################"
cd /home/$USER
git clone https://aur.archlinux.org/nerd-fonts-fantasque-sans-mono.git
chown -R $USER:users /home/$USER/nerd-fonts-fantasque-sans-mono   
chown -R $USER:users /home/$USER/nerd-fonts-fantasque-sans-mono/PKGBUILD 
cd /home/$USER/nerd-fonts-fantasque-sans-mono
sudo -u $USER  makepkg -si --noconfirm
rm -Rf /home/$USER/nerd-fonts-fantasque-sans-mono

echo "########################################################################################"
echo "###################    <<< установка драйвера на WiFi(AUR) >>>    ######################"
echo "########################################################################################"
cd /home/$USER
git clone https://aur.archlinux.org/rtl8821ce-dkms-git.git
chown -R $USER:users /home/$USER/rtl8821ce-dkms-git   
chown -R $USER:users /home/$USER/rtl8821ce-dkms-git/PKGBUILD 
cd /home/$USER/rtl8821ce-dkms-git
sudo -u $USER  makepkg -si --noconfirm
rm -Rf /home/$USER/rtl8821ce-dkms-git

systemctl enable dhcpcd

echo "Настройка Системы Завершена"
