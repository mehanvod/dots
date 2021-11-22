#!/usr/bin/env bash

## Файлы кофигурации ##
echo  'Скопировать файлы кофигурации в домашнюю директорию ? :'
while
    read -n1 -p  "
    1 - Awesome WM

    2 - KDE Plasma

    0 - нет: " cp_home_conf # sends right after the keypress
    echo ''
    [[ "$cp_home_conf" =~ [^120] ]]
do
    :
done
if [[ $cp_home_conf == 1 ]]; then
    cp -a -T /home/$USER/Documents/dotfiles/home_dir/. /home/$USER/Public/001
    tput setaf 4
    echo 'Файлы кофигурации Awesome WM скопированы.'
    tput sgr0
elif [[ $cp_home_conf == 2 ]]; then
    cp -a -T /home/$USER/Documents/plasma/. /home/$USER/Public/001
    tput setaf 4
    echo 'Файлы кофигурации KDE Plasma скопированы.'
    tput sgr0
elif [[ $cp_home_conf == 0 ]]; then
    tput setaf 8
    echo 'Копирование файлов кофигурации пропущено.'
    tput sgr0
fi
