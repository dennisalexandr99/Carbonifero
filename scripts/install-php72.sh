#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.php72 ]
then
    echo "PHP 7.2 already Installed"
    exit 0
fi

touch /home/vagrant/.php72

sudo dpkg --configure -a
sudo add-apt-repository ppa:ondrej/php
sudo apt-get -y update
sudo apt-get -y install php7.2 php7.2-cli php7.2-common php7.2-mbstring php7.2-gd php7.2-intl php7.2-xml php7.2-mysql php7.2-zip