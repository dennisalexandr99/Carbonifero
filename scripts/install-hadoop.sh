#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.hadoop ]
then
    echo "Hadoop already Installed"
    exit 0
fi

touch /home/vagrant/.hadoop

sudo apt-get -y remove --purge glusterfs-server
cd /usr/local/bin
sudo wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz 2>/dev/null
sudo tar -xvf hadoop-2.7.3.tar.gz 2>/dev/null
sudo rm hadoop-2.7.3.tar.gz

block="## Generate By Carbofinero for Hadoop
export HADOOP_HOME='/usr/local/bin/hadoop-2.7.3'
export PATH=$PATH:/usr/local/bin/hadoop-2.7.3/bin
export PATH=$PATH:/usr/local/bin/hadoop-2.7.3/sbin
export HADOOP_MAPRED_HOME=/usr/local/bin/hadoop-2.7.3
export HADOOP_COMMON_HOME=/usr/local/bin/hadoop-2.7.3
export HADOOP_HDFS_HOME=/usr/local/bin/hadoop-2.7.3
export YARN_HOME=/usr/local/bin/hadoop-2.7.3"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc
