#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.scala ]
then
    echo "Scala already Installed"
    exit 0
fi

touch /home/vagrant/.scala

sudo dpkg --configure -a
cd ~
sudo apt-get -y update
sudo apt-get -y install scala