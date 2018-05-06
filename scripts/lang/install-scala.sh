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

# Download or Copy File from Local
sudo dpkg --configure -a
cd /vagrant/downloads
if [ -e "scala-2.12.6.deb" ]; then
    echo "Installing Scala from Local File"
else
    echo "Installing Scala from Server"
    sudo wget "https://www.scala-lang.org/files/archive/scala-2.12.6.deb" 2>/dev/null
fi

# Copy file from /vagrant/resources
sudo dpkg -i scala-2.11.8.deb

# Install SBT
cd ~
sudo echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt
