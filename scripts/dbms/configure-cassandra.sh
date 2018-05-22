#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.ccassandra ]
then
    echo "Cassanda already Configured"
    exit 0
fi

touch /home/vagrant/.ccassandra
echo "Reconfigured Cassandra, This will format all Configuration"

# cd /usr/local/bin/cassandra
cd /usr/local/bin/cassandra

# Create Directory
sudo mkdir -p data
sudo mkdir -p logs
sudo chown vagrant -R data logs
sudo chmod 777 -R data logs

# Delete default Casssandra dataset
sudo rm -rf /var/lib/cassandra/data/system/*

# Edit hbase Configuration
sudo cp /vagrant/resources/cassandra/cassandra conf/cassandra.yaml -f

# Split IP
IFS='.' read -r -a array <<< $1
numNodes=$2
sudo su

# Generate IP
seeds=""
for ((i=1;i<=numNodes;i++));
do
    if [ "$i" = "1" ]; then
        master="${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+$i))"
    fi
    seeds="$seeds,${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+$i))"
done

seeds=${seeds#?}

# Change Default Master
sudo sed -i -e s/MASTER_IP/$master/ conf/cassandra.yaml
# Change Seeds
sudo sed -i -e s/SEEDS_IP/$seeds/ conf/cassandra.yaml