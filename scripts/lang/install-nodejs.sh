#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.nodejs ]
then
    echo "NodeJS already Installed"
    exit 0
fi

touch /home/vagrant/.nodejs

sudo dpkg --configure -a
cd ~

curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get -y update
sudo apt-get -y install nodejs
sudo apt-get -y install npm
sudo apt-get -y install build-essential