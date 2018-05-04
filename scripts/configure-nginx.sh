#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

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

# Configure Block Server
if [ "$2" = "default" ]; then
    server="default_server"
else
    server=""
fi

folder="$(echo $3 | awk '{gsub(/\//,"\\\/")}1' 2>/dev/null)"
domain=$2
ip=$1

sudo cp /vagrant/resources/nginx/block temp$2 -f
# Change Default Server
sudo sed -i -e s/DEFAULT/$server/ temp$2
# Change Domain
sudo sed -i -e s/DOMAIN/$domain/ temp$2
# Change IP
sudo sed -i -e s/IP_ADDRESS/$ip/ temp$2
# # Change Folder
sudo sed -i -e s/FOLDER/$folder/ temp$2
# Change PHP Version
sudo sed -i -e s/PHP_VERSION/$php_version/ temp$2
# Copy File
sudo cp temp$2 /etc/nginx/sites-available/$2
sudo ln -fs /etc/nginx/sites-available/$2 /etc/nginx/sites-enabled/$2
# Remove File
sudo rm temp$2 -f
sudo service nginx restart
