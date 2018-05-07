#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.hbase ]
then
    echo "HBase already Installed"
    exit 0
fi

touch /home/vagrant/.hbase

# Download or Copy File from Local
cd /vagrant/downloads
if [ -e "hbase-1.2.6-bin.tar.gz" ]; then
    echo "Installing HBase from Local File"
else
    echo "Installing HBase from Server"
    sudo wget http://www-eu.apache.org/dist/hbase/1.2.6/hbase-1.2.6-bin.tar.gz 2>/dev/null
fi

# Copy File from /vagrant/downloads
sudo cp hbase-1.2.6-bin.tar.gz /usr/local/bin/hbase-1.2.6-bin.tar.gz -f

# Extracting Files
cd /usr/local/bin
sudo tar -xvf hbase-1.2.6-bin.tar.gz 2>/dev/null
sudo mv hbase-1.2.6 hbase
sudo rm hbase-1.2.6-bin.tar.gz

# Add Path
HBASE_HOME=/usr/local/bin/hbase
block="## Generate By Carbofinero for HBase
export HBASE_HOME='$HBASE_HOME'
export PATH=$PATH:$HBASE_HOME/bin:/usr/local/bin/zookeeper/bin:/usr/local/bin/hadoop/bin:/usr/local/bin/hadoop/sbin:/usr/local/bin/zookeeper/sbin:/usr/local/bin/spark/bin:/usr/local/bin/spark/sbin"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc