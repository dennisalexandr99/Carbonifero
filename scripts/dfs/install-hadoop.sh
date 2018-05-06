#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.hadoop ]
then
    echo "Hadoop already Installed"
    exit 0
fi

touch /home/vagrant/.hadoop

# Download or Copy File from Local
sudo dpkg --configure -a
cd /vagrant/downloads
sudo apt-get -y remove --purge glusterfs-server
if [ -e "hadoop-2.7.3.tar.gz" ]; then
    echo "Installing HadoopFS from Local File"
else
    echo "Installing HadoopFS from Server"
    sudo wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz 2>/dev/null
fi

# Copy Files from /vagrant/downloads
sudo cp hadoop-2.7.3.tar.gz /usr/local/bin/hadoop-2.7.3.tar.gz -f

# Extracting Files
cd /usr/local/bin
sudo tar -xvf hadoop-2.7.3.tar.gz 2>/dev/null
sudo mv hadoop-2.7.3 hadoop
sudo rm hadoop-2.7.3.tar.gz

# Add Path
HADOOP_HOME=/usr/local/bin/hadoop
block="## Generate By Carbofinero for Hadoop
export HADOOP_HOME='$HADOOP_HOME'
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc
