#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.extras ]
then
    echo "Extras already Installed"
    exit 0
fi

touch /home/vagrant/.extras

sudo apt-get -y install software-properties-common
sudo apt-get -y install apt-transport-https
sudo apt-get -y install curl

#Fix Bug
sudo apt-get -y install language-pack-en-base
sudo locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8