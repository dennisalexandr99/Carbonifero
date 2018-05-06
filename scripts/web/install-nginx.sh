#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.nginx ]
then
    echo "Nginx already Installed"
    exit 0
fi

touch /home/vagrant/.nginx

sudo dpkg --configure -a
cd ~

sudo apt-get -y remove --purge apache2 lighttpd
sudo apt-get -y update
sudo apt-get -y install nginx
sudo systemctl enable nginx

#Configuring Fresh Configuration
php_version="$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1,2,3)"

# Install PHP 7.0
if [ "$php_version" = "" ]; then
    sudo echo "Installing PHP 7.0"
    sudo dpkg --configure -a
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-get -y update
    sudo apt-get -y install php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip
    php_version="7.0"
fi

sudo apt-get -y install php$php_version-fpm