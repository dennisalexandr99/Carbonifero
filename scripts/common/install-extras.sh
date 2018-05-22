#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.extras ]
then
    echo "Extras already Installed"
    exit 0
fi

touch /home/vagrant/.extras

# Reconfigure Package
sudo dpkg --configure -a
cd ~

# Install Apps
sudo apt-get -y update
sudo apt-get -y install software-properties-common
sudo apt-get -y install apt-transport-https
sudo apt-get -y install curl
sudo apt-get -y install python-software-properties debconf-utils
sudo apt-get -y install python-pip
sudo apt-get -y install mosquitto
pip install paho-mqtt

#Fix Bug
sudo apt-get -y install language-pack-en-base
sudo locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#Create Directory for Downloads File
sudo mkdir -p /vagrant/downloads
sudo chown vagrant -R /vagrant/downloads
sudo chmod 777 -R /vagrant/downloads