#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.java ]
then
    echo "Java already Installed"
    exit 0
fi

touch /home/vagrant/.java

sudo dpkg --configure -a
sudo apt-get install -y python-software-properties debconf-utils
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get -y update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer 2>/dev/null

block="## Generate By Carbofinero for Java
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin"

sudo echo "$block" >> ~/.bashrc