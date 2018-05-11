#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.cassandra ]
then
    echo "Cassandra already Installed"
    exit 0
fi

touch /home/vagrant/.cassandra

# Download or Copy File from Local
cd /vagrant/downloads
if [ -e "apache-cassandra-3.11.2-bin.tar.gz" ]; then
    echo "Installing Cassandra from Local File"
else
    echo "Installing Cassandra from Server"
    sudo wget http://mirror.cc.columbia.edu/pub/software/apache/cassandra/3.11.2/apache-cassandra-3.11.2-bin.tar.gz 2>/dev/null
fi

# Copy File from /vagrant/downloads
sudo cp apache-cassandra-3.11.2-bin.tar.gz /usr/local/bin/apache-cassandra-3.11.2-bin.tar.gz -f

# Extracting Files
cd /usr/local/bin
sudo tar -xvf apache-cassandra-3.11.2-bin.tar.gz 2>/dev/null
sudo mv apache-cassandra-3.11.2 cassandra
sudo rm apache-cassandra-3.11.2-bin.tar.gz

# Add Path
CASSANDRA_HOME=/usr/local/bin/cassandra
block="## Generate By Carbofinero for Cassandra
export CASSANDRA_HOME='$CASSANDRA_HOME'
export PATH=$PATH:$CASSANDRA_HOME/bin:/usr/local/bin/zookeeper/bin:/usr/local/bin/hadoop/bin:/usr/local/bin/hadoop/sbin:/usr/local/bin/zookeeper/sbin:/usr/local/bin/spark/bin:/usr/local/bin/spark/sbin"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc