#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.czookeeper ]
then
    echo "Zookeeper already Configured"
    exit 0
fi

touch /home/vagrant/.czookeeper
echo "Reconfigured Zookeeper, This will format all Configuration"

numNodes=$1

cd /usr/local/bin/zookeeper

# Create Directory
sudo mkdir -p data
sudo mkdir -p logs
sudo chown vagrant -R data logs
sudo chmod 777 -R data logs

# Make an ID
sudo echo "$1" > data/myid 
sudo chown vagrant -R data/myid
sudo chmod 777 -R data/myid

# Edit Zookeeper Environment
sudo cat /vagrant/resources/zookeeper/env >> conf/java.env

# Edit Zookeeper Configuration
sudo cp /vagrant/resources/zookeeper/zoo conf/zoo.cfg -f
sudo echo "" >> conf/zoo.cfg;
for ((i=1;i<=numNodes;i++));
do
    sudo echo "server.$i=carbonifero$i:2888:3888" >> conf/zoo.cfg;
done