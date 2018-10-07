#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.java ]
then
    echo "Java already Installed"
    exit 0
fi

touch /home/vagrant/.java

# Download or Copy File from Local
sudo dpkg --configure -a
cd /vagrant/downloads
if [ -e "jdk-8u162-linux-x64.tar.gz" ]; then
    echo "Installing Java 8 from Local File"
else
    echo "Installing Java 8 from Server"
    sudo wget "https://mail-tp.fareoffice.com/java/jdk-8u162-linux-x64.tar.gz" 2>/dev/null
fi

# Copy file from /vagrant/resources
sudo mkdir -p /usr/lib/jvm
sudo cp jdk-8u162-linux-x64.tar.gz /usr/lib/jvm/jdk-8u162-linux-x64.tar.gz -f

# Extracting File
cd /usr/lib/jvm
sudo tar -xf jdk-8u162-linux-x64.tar.gz 2>/dev/null
sudo mv jdk1.8* /usr/lib/jvm/java-8-oracle
sudo rm jdk-8u162-linux-x64.tar.gz

# Configuring Java
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/jre/bin/java 1091
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-oracle/bin/javac 1091

# Edit Java Profile
sudo cp /vagrant/resources/java/jdk /etc/profile.d/jdk.sh -f
source /etc/profile.d/jdk.sh

# Add Path
block="## Generate By Carbofinero for Java
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin"

cd ~
sudo echo "$block" >> ~/.bashrc
source .bashrc