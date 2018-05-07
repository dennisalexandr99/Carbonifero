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
sudo chown vagrant -R data logs
sudo chmod 777 -R data logs

# Edit Spark Environment
sudo cat /vagrant/resources/spark/env >> spark-env.sh;