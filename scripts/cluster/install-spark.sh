#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.spark ]
then
    echo "Spark already Installed"
    exit 0
fi

touch /home/vagrant/.spark

# Download or Copy file from Local
sudo dpkg --configure -a
cd /vagrant/downloads
if [ -e "spark-2.3.0-bin-hadoop2.7.tgz" ]; then
    echo "Installing Spark from Local File"
else
    echo "Installing Spark from Server"
    sudo wget http://www-us.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz 2>/dev/null
fi

# Copy File from /vagrant/downloads
sudo cp spark-2.3.0-bin-hadoop2.7.tgz /usr/local/bin/spark-2.3.0-bin-hadoop2.7.tgz -f

# Extracting Files
cd /usr/local/bin
sudo tar -xvf spark-2.3.0-bin-hadoop2.7.tgz 2>/dev/null
sudo mv spark-2.3.0-bin-hadoop2.7 spark
sudo rm spark-2.3.0-bin-hadoop2.7.tgz

# Add Path
SPARK_HOME=/usr/local/bin/spark
block="## Generate By Carbofinero for Spark
export SPARK_HOME='$SPARK_HOME'
export PATH=$PATH:$SPARK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc