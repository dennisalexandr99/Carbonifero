#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.zookeeper ]
then
    echo "Zookeeper already Installed"
    exit 0
fi

touch /home/vagrant/.zookeeper

# Download or Copy file from Local
sudo dpkg --configure -a
cd /vagrant/downloads
if [ -e "zookeeper-3.4.12.tar.gz" ]; then
    echo "Installing Zookeeper from Local File"
else
    echo "Installing Zookeeper from Server"
    sudo wget http://www-eu.apache.org/dist/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz 2>/dev/null
fi

# Copy File from /vagrant/downloads
sudo cp zookeeper-3.4.12.tar.gz /usr/local/bin/zookeeper-3.4.12.tar.gz -f

# Extracting Files
cd /usr/local/bin
sudo tar -xvf zookeeper-3.4.12.tar.gz 2>/dev/null
sudo mv zookeeper-3.4.12 zookeeper
sudo rm zookeeper-3.4.12.tar.gz

# Add Path
ZOOKEEPER_HOME=/usr/local/bin/zookeeper
block="## Generate By Carbofinero for Zookeeper
export ZOOKEEPER_HOME='$ZOOKEEPER_HOME'
export PATH=$PATH:$ZOOKEEPER_HOME/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc