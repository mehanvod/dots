#!/usr/bin/env bash
# Install script for Arch Linux (UEFI & systemd-boot)
# autor: Sergey Prostov
# https://raw.githubusercontent.com/mehanvod/dots/master/.bin/berb2.sh
# wget git.io/berb2.sh
# curl -OL git.io/berb2.sh

DISK="sdb"

sed -i 's/^#Color/Color/g' /etc/pacman.conf
sed -i 's/^#TotalDownload/TotalDownload/g' /etc/pacman.conf
sed -i 's/^#CheckSpace/CheckSpace/g' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
sed -i 's/.*\VerbosePkgLists\.*/&\nILoveCandy/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

timedatectl set-ntp true
pacman -Sy  --noconfirm

# check kernel for install headers
kernel=`pacman -Qe linux 2>/dev/null | grep -o "^linux"`
kernel=`echo $kernel | sed -E 's/([a-z\-]+)/\1-headers/'`
kernel_lts=`pacman -Qe linux-lts 2>/dev/null | grep -o "^linux-lts"`
kernel_lts=`echo $kernel_lts | sed -E 's/([a-z\-]+)/\1-headers/'`
kernel_zen=`pacman -Qe linux-zen 2>/dev/null | grep -o "^linux-zen"`
kernel_zen=`echo $kernel_zen | sed -E 's/([a-z\-]+)/\1-headers/'`
kernel_hardened=`pacman -Qe linux-hardened 2>/dev/null | grep -o "^linux-hardened"`
kernel_hardened=`echo $kernel_hardened | sed -E 's/([a-z\-]+)/\1-headers/'`
headers=`echo "$kernel $kernel_lts $kernel_zen $kernel_hardened"`

echo "#####################################################################"
echo ""
echo " Установка DE(WM). Выберите пункт для установки "
while
    read -n1 -p  "
    1 - Awesome(WM)+lightdm

    2 - Xfce+lightdm

    3 - KDE(Plasma)

    4 - gmome

    0 - пропустить " x_de
    echo ''
    [[ "$x_de" =~ [^12340] ]]
do
    :
done
if [[ $x_de == 0 ]]; then
  echo 'уcтановка DE пропущена'

elif [[ $x_de == 1 ]]; then
pack="$headers xorg-server xf86-input-synaptics \
awesome lightdm lightdm-gtk-greeter nano man-db dhcpcd \
dialog wpa_supplicant netctl iw net-tools wmctrl \
gtk-engines gtk-engine-murrine qt5ct picom \
gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g gtk2-perl \
alsa-utils gstreamer pulseaudio pulseaudio-alsa pavucontrol \
termite zsh zsh-syntax-highlighting zsh-autosuggestions \
openssh pcmanfm gxkb unclutter papirus-icon-theme \
curl wget git rsync python-pip unzip file-roller unrar p7zip \
gsimplecal redshift numlockx firefox firefox-i18n-ru \
ttf-dejavu ttf-liberation ttf-font-awesome awesome-terminal-fonts \
otf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono"
pacman -S --noconfirm --needed $pack
systemctl enable lightdm

cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOF
[greeter]
background=/usr/share/pixmaps/002.jpg
theme-name=Fantome
icon-theme-name=Papirus
font-name=Iosevka 9
xft-antialias=true
xft-dpi=96
xft-hintstyle=true
xft-rgba=rgb
indicators=~clock;~session;~power;
# position=5% 40%
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
EOF

cat > /etc/modprobe.d/radeon.conf << EOF
options radeon si_support=0
options radeon cik_support=0
EOF

cat > /etc/modprobe.d/amdgpu.conf << EOF
options amdgpu si_support=1
options amdgpu cik_support=1
EOF

cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << EOF
Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "TearFree" "true"
    Option "ShadowPrimary" "true"
EndSection
EOF

cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us,ru"
        Option "XkbModel" "pc105"
        Option "XkbVariant" "qwerty"
        Option "XkbOptions" "grp:lalt_lshift_toggle,grp_led:scroll"
EndSection
EOF

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf
sed -i 's/#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=35"/g' /etc/profile.d/freetype2.sh

echo "Awesome(WM) успешно установлено"

elif [[ $x_de == 2 ]]; then
pack="$headers xorg-server xf86-input-synaptics \
xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
nano man-db dhcpcd gvfs gvfs-afc gvfs-mtp gvfs-smb ntfs-3g \
gtk-engines gtk-engine-murrine xdg-user-dirs-gtk qt5ct picom \
alsa-utils gstreamer pulseaudio pulseaudio-alsa pavucontrol \
bash-completion gtk2-perl termite zsh zsh-syntax-highlighting zsh-autosuggestions \
openssh papirus-icon-theme dialog wpa_supplicant iw net-tools wmctrl \
openssh networkmanager networkmanager-openconnect networkmanager-openvpn \
networkmanager-pptp networkmanager-vpnc network-manager-applet \
curl wget git rsync python-pip unzip file-roller unrar p7zip \
gsimplecal redshift numlockx firefox firefox-i18n-ru \
ttf-dejavu ttf-liberation ttf-font-awesome awesome-terminal-fonts \
otf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono"
pacman -S --noconfirm --needed $pack
systemctl enable lightdm NetworkManager

cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOF
[greeter]
background=/usr/share/pixmaps/002.jpg
theme-name=Fantome
icon-theme-name=Papirus
font-name=Roboto 9
xft-antialias=true
xft-dpi=96
xft-hintstyle=true
xft-rgba=rgb
indicators=~clock;~session;~power;
# position=5% 40%
EOF

sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/g' /etc/lightdm/lightdm.conf

cat > /etc/modprobe.d/radeon.conf << EOF
options radeon si_support=0
options radeon cik_support=0
EOF

cat > /etc/modprobe.d/amdgpu.conf << EOF
options amdgpu si_support=1
options amdgpu cik_support=1
EOF

cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << EOF
Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "TearFree" "true"
EndSection
EOF

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf
sed -i 's/#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=35"/g' /etc/profile.d/freetype2.sh

echo "Xfce успешно установлено"

elif [[ $x_de == 3 ]]; then
pack="$headers xorg-server plasma-meta plasma plasma-pa plasma-desktop kde-system-meta sddm sddm-kcm \
kde-utilities-meta kio-extras konsole kde-applications \
ntfs-3g pulseaudio pavucontrol \
zsh zsh-syntax-highlighting zsh-autosuggestions pacman-contrib \
openssh networkmanager networkmanager-openvpn network-manager-applet ppp \
curl wget git rsync python-pip unzip unrar p7zip nano man-db dhcpcd \
iw net-tools firefox firefox-i18n-ru"
pacman -S --noconfirm --needed $pack
pacman -R konqueror --noconfirm
systemctl enable sddm.service -f
systemctl enable NetworkManager

cat > /etc/modprobe.d/radeon.conf << EOF
options radeon si_support=0
options radeon cik_support=0
EOF

cat > /etc/modprobe.d/amdgpu.conf << EOF
options amdgpu si_support=1
options amdgpu cik_support=1
EOF

cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << EOF
Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "TearFree" "true"
EndSection
EOF

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf

echo "Plasma успешно установлено"

elif [[ $x_de == 4 ]]; then
pack="$headers xorg-server gnome gnome-extra gdm dkms bc \
zsh zsh-syntax-highlighting zsh-autosuggestions \
curl wget git rsync nano man-db dhcpcd \
openssh networkmanager networkmanager-openconnect networkmanager-openvpn \
networkmanager-pptp networkmanager-vpnc network-manager-applet \
firefox firefox-i18n-ru ttf-dejavu ttf-liberation"
pacman -S --noconfirm --needed $pack
systemctl enable gdm.service -f
systemctl enable NetworkManager

cat > /etc/modprobe.d/radeon.conf << EOF
options radeon si_support=0
options radeon cik_support=0
EOF

cat > /etc/modprobe.d/amdgpu.conf << EOF
options amdgpu si_support=1
options amdgpu cik_support=1
EOF

cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << EOF
Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "TearFree" "true"
EndSection
EOF

echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /etc/environment
echo 'vm.swappiness=10' >> /etc/sysctl.d/99-sysctl.conf

echo " Gnome успешно установлен "
fi

mkdir /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/100-systemd-boot.hook << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

echo ""
echo " Добавим dhcpcd в автозагрузку( для проводного интернета, который  получает настройки от роутера ) ? "
echo ""
echo "при необходимости это можно будет сделать уже в установленной системе "
while
    read -n1 -p  "
    1 - включить dhcpcd

    0 - не включать dhcpcd " x_dhcpcd
    echo ''
    [[ "$x_dhcpcd" =~ [^10] ]]
do
    :
done
if [[ $x_dhcpcd == 0 ]]; then
  echo ' dhcpcd не включен в автозагрузку, при необходиости это можно будет сделать уже в установленной системе '
elif [[ $x_dhcpcd == 1 ]]; then
systemctl enable dhcpcd.service
clear
echo "Dhcpcd успешно добавлен в автозагрузку"
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
127.0.0.1       localhost
::1             localhost
127.0.1.1       $HOST.localdomain       $HOST
192.168.0.104   homepage.loc
192.168.0.104   www.homepage.loc
192.168.0.104   homepage2.loc
192.168.0.104   www.homepage2.loc
192.168.0.104   homepage3.loc
192.168.0.104   www.homepage3.loc
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
sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

usermod -c 'Сергей Простов' $USER

echo " Очистим папку конфигов, кеш, и скрытые каталоги в /home/$USER от старой системы ? "
while
    read -n1 -p  "
    1 - да

    0 - нет: " i_rm      # sends right after the keypress
    echo ''
    [[ "$i_rm" =~ [^10] ]]
do
    :
done
if [[ $i_rm == 0 ]]; then
clear
echo " очистка пропущена "
elif [[ $i_rm == 1 ]]; then
rm -rf /home/$USER/.*
clear
echo " очистка завершена "
fi

# graphics driver
amd=$(lspci | grep -e VGA -e 3D | grep 'AMD' 2> /dev/null || echo '')
nvidia=$(lspci | grep -e VGA -e 3D | grep 'NVIDIA' 2> /dev/null || echo '')
intel=$(lspci | grep -e VGA -e 3D | grep 'Intel' 2> /dev/null || echo '')
if [[ -n "$nvidia" ]]; then
  pacman -S --noconfirm --needed nvidia
fi

if [[ -n "$amd" ]]; then
  pacman -S --noconfirm --needed xf86-video-amdgpu
fi

if [[ -n "$intel" ]]; then
  pacman -S --noconfirm --needed xf86-video-intel
fi

if [[ -n "$nvidia" && -n "$intel" ]]; then
  pacman -S --noconfirm --needed bumblebee
  gpasswd -a $USER bumblebee
  systemctl enable bumblebeed
fi

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
echo  " этап пропущен "
fi

hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf

cat > /etc/vconsole.conf <<EOF
LOCALE="ru_RU.UTF-8"
KETMAP="ruwin_alt_sh-UTF-8"
FONT="cyr-sun16"
CONSOLEMAP=""
TIMEZONE="Europe/Moscow"
HARDWARECLOCK="UTC"
USECOLOR="yes"
EOF

sed -i 's/MODULES=()/MODULES=(amdgpu radeon)/g' /etc/mkinitcpio.conf
sed -i 's/#SystemMaxUse=/SystemMaxUse=5M/g' /etc/systemd/journald.conf

mkinitcpio -p linux
clear

pacman -S --noconfirm --needed efibootmgr
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force

# Bootloader
# Use system-boot for EFI mode, and grub for others
if [[ -d "/sys/firmware/efi/efivars" ]]; then
  bootctl install

  cat <<EOF > /boot/loader/entries/arch.conf
    title    Arch Linux
    linux    /vmlinuz-linux
    initrd   /amd-ucode.img
    initrd   /initramfs-linux.img
    options  root=/dev/sdb2 rw
    options  quiet splash acpi_backlight=vendor rd.udev.log_priority=3
EOF

  cat <<EOF > /boot/loader/loader.conf
    default  arch.conf
    timeout  5
    console-mode max
    editor   no
EOF

kernel_lts=`pacman -Qe linux-lts 2>/dev/null | grep -o "^linux-lts"`
  if [[ -n "$kernel_lts" ]]; then
    sed -i 's#/vmlinuz-linux#/vmlinuz-linux-lts#' /boot/loader/entries/arch.conf
    sed -i 's#/initramfs-linux.img#/initramfs-linux-lts.img#' /boot/loader/entries/arch.conf
  fi
kernel_zen=`pacman -Qe linux-zen 2>/dev/null | grep -o "^linux-zen"`
  if [[ -n "$kernel_zen" ]]; then
    sed -i 's#/vmlinuz-linux#/vmlinuz-linux-zen#' /boot/loader/entries/arch.conf
    sed -i 's#/initramfs-linux.img#/initramfs-linux-zen.img#' /boot/loader/entries/arch.conf
  fi
kernel_hardened=`pacman -Qe linux-hardened 2>/dev/null | grep -o "^linux-hardened"`
  if [[ -n "$kernel_hardened" ]]; then
    sed -i 's#/vmlinuz-linux#/vmlinuz-linux-hardened#' /boot/loader/entries/arch.conf
    sed -i 's#/initramfs-linux.img#/initramfs-linux-hardened.img#' /boot/loader/entries/arch.conf
  fi

is_intel_cpu=$(lscpu | grep 'Intel' &> /dev/null && echo 'yes' || echo '')
  if [[ -n "$is_intel_cpu" ]]; then
    sed -i 's#/amd-ucode.img#/intel-ucode.img#' /boot/loader/entries/arch.conf
  fi

  # remove leading spaces
  sed -i 's#^ \+##g' /boot/loader/entries/arch.conf
  sed -i 's#^ \+##g' /boot/loader/loader.conf

  # modify root partion in loader conf
  root_part=$(mount | grep 'on / ' | cut -d' ' -f1 | df / | tail -1 | cut -d' ' -f1)
  pu=$(blkid -s PARTUUID -o value $root_part)
  pup=PARTUUID="$pu"
  sed -i "s#/dev/sdb2#$pup#" /boot/loader/entries/arch.conf
else
  disk=$(df / | tail -1 | cut -d' ' -f1 | sed 's#[0-9]\+##g')
  pacman --noconfirm -S grub os-prober
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force "$disk"
  grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "################################################################"
echo ""
echo " Примонтировать HDD ? : "
while
    read -n1 -p  "
    1 - да,

    0 - нет: " mount_hdd # sends right after the keypress
    echo ''
    [[ "$mount_hdd" =~ [^10] ]]
do
    :
done
if [[ $mount_hdd == 0 ]]; then
    echo 'Монтирование пропущено'
elif [[ $mount_hdd == 1 ]]; then
[ -d /mnt/files ] || mkdir -p /mnt/files
mount /dev/sda1 /mnt/files
chmod 0777 /mnt/files
hdd_part=/dev/sda1
hdd_uuid=$(blkid -s UUID -o value $hdd_part)
echo "# /dev/sda1 LABEL=Files
UUID=$hdd_uuid   /mnt/files  ext4        rw,relatime 0 0" | tee --append /etc/fstab
ln -s /mnt/files/Documents /home/$USER/Documents
ln -s /mnt/files/Downloads /home/$USER/Downloads
ln -s /mnt/files/Music /home/$USER/Music
ln -s /mnt/files/Pictures /home/$USER/Pictures
ln -s /mnt/files/Public /home/$USER/Public
ln -s /mnt/files/Templates/home/$USER/Templates
ln -s /mnt/files/Videos /home/$USER/Videos
fi

echo "################################################################"
echo ""
echo " Установим шрифт ttf-iosevka ? : "
while
    read -n1 -p  "
    1 - да,

    0 - нет: " inst_iosevka # sends right after the keypress
    echo ''
    [[ "$inst_iosevka" =~ [^10] ]]
do
    :
done
if [[ $inst_iosevka == 0 ]]; then
  echo 'уcтановка  пропущена'
elif [[ $inst_iosevka == 1 ]]; then
cd /home/$USER
git clone https://aur.archlinux.org/ttf-iosevka.git
chown -R $USER:users /home/$USER/ttf-iosevka
chown -R $USER:users /home/$USER/ttf-iosevka/PKGBUILD
cd /home/$USER/ttf-iosevka
sudo -u $USER  makepkg -si --noconfirm
rm -Rf /home/$USER/ttf-iosevka
clear
fi

echo "################################################################"
echo ""
echo " Установим шрифт ttf-material-design-icons-extended ? : "
while
    read -n1 -p  "
    1 - да,

    0 - нет: " inst_mdie # sends right after the keypress
    echo ''
    [[ "$inst_mdie" =~ [^10] ]]
do
    :
done
if [[ $inst_mdie == 0 ]]; then
  echo 'уcтановка  пропущена'
elif [[ $inst_mdie == 1 ]]; then
cd /home/$USER
git clone   https://aur.archlinux.org/ttf-material-design-icons-extended.git
chown -R $USER:users /home/$USER/ttf-material-design-icons-extended
chown -R $USER:users /home/$USER/ttf-material-design-icons-extended/PKGBUILD
cd /home/$USER/ttf-material-design-icons-extended
sudo -u $USER  makepkg -si --skipinteg --noconfirm
rm -Rf /home/$USER/ttf-material-design-icons-extended
clear
fi

echo "################################################################"
echo ""
echo " Установим драйвер на WiFi(AUR) ? : "
while
    read -n1 -p  "
    1 - да,

    0 - нет: " inst_rtl # sends right after the keypress
    echo ''
    [[ "$inst_rtl" =~ [^10] ]]
do
    :
done
if [[ $inst_rtl == 0 ]]; then
  echo 'уcтановка  пропущена'
elif [[ $inst_rtl == 1 ]]; then
cd /home/$USER
git clone https://aur.archlinux.org/rtl8821ce-dkms-git.git
chown -R $USER:users /home/$USER/rtl8821ce-dkms-git
chown -R $USER:users /home/$USER/rtl8821ce-dkms-git/PKGBUILD
cd /home/$USER/rtl8821ce-dkms-git
sudo -u $USER  makepkg -si --noconfirm
rm -Rf /home/$USER/rtl8821ce-dkms-git
clear
fi

echo "################################################################"
echo ""
echo " Скопировать файлы кофигурации Awesome WM в домашнюю директорию ? : "
while
    read -n1 -p  "
    1 - да,

    0 - нет: " cp_home_awe # sends right after the keypress
    echo ''
    [[ "$cp_home_awe" =~ [^10] ]]
do
    :
done
if [[ $cp_home_awe == 0 ]]; then
  echo 'уcтановка  пропущена'
elif [[ $cp_home_awe == 1 ]]; then
cp -a -T /home/$USER/Documents/dotfiles/home_dir/. /home/$USER
clear
fi

echo "################################################################"
echo ""
echo " Скопировать файлы кофигурации KDE Plasma в домашнюю директорию ? : "
while
    read -n1 -p  "
    1 - да,

    0 - нет: " cp_home_kde # sends right after the keypress
    echo ''
    [[ "$cp_home_kde" =~ [^10] ]]
do
    :
done
if [[ $cp_home_kde == 0 ]]; then
    echo 'уcтановка  пропущена'
elif [[ $cp_home_kde == 1 ]]; then
cd /home/$USER/Documents/y_disk/archlinux/de/kde
tar xf plasma*.tar.gz -C /home/$USER
fi

clear
exit
exit
