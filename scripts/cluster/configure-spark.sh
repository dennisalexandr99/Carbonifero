#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.cspark ]
then
    echo "Spark already Configured"
    exit 0
fi

touch /home/vagrant/.cspark
echo "Reconfigured Spark, This will format all Configuration"

# Move Directory
cd /usr/local/bin/spark

# Create Directory
sudo mkdir -p data
sudo mkdir -p logs
sudo mkdir -p work
sudo chown vagrant -R data logs work
sudo chmod 777 -R data logs work

# Configure Master and Slave
numNodes=$2+1
divider=$3
numReplica=$((numNodes / divider))

if [ "$numReplica" = "0" ]; then
    numReplica=1
fi

# Create Master and Slave
cd conf
sudo su

# Edit Spark Environment
IFS='.' read -r -a array <<< $1
master="${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+1))"
node="${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+$4))"

sudo cp /vagrant/resources/spark/env spark-env.sh

# Change Default Master and node
sudo sed -i -e s/MASTER_IP/$master/ spark-env.sh
sudo sed -i -e s/NODE_IP/$node/ spark-env.sh

# Master
sudo echo "master" >> masters;

# Slave
for ((i=1;i<numNodes;i++));
do
    sudo echo "carbonifero-$i" >> slaves;
done