#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.chbase ]
then
    echo "HBase already Configured"
    exit 0
fi

touch /home/vagrant/.chbase
echo "Reconfigured HBase, This will format all Configuration"

numNodes=$1

cd /usr/local/bin/hbase

# Create Directory
sudo mkdir -p data
sudo mkdir -p logs
sudo chown vagrant -R data logs
sudo chmod 777 -R data logs

# Edit hbase Environment
sudo cat /vagrant/resources/hbase/env >> conf/hbase-env.sh

# Edit hbase Configuration
sudo cp /vagrant/resources/hbase/hbase-site conf/hbase-site.xml -f