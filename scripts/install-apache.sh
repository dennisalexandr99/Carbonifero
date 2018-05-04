#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.apache ]
then
    echo "Apache already Installed"
    exit 0
fi

touch /home/vagrant/.apache

sudo apt-get -y remove --purge nginx-extras lighttpd
sudo apt-get -y update
sudo apt-get -y install apache2

php_version="$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1,2,3)"
# Install PHP 7.0
if [ "$php_version" = "" ]; then
    echo "Installing PHP 7.0"
    sudo dpkg --configure -a
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-get -y update
    sudo apt-get -y install php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip
    php_version="7.0"
fi
sudo apt-get -y install libapache2-mod-php$php_version
sudo sed -i -e s/None/All/ /etc/apache2/apache2.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite

sudo systemctl enable apache2