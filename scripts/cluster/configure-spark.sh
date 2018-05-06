#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.cspark ]
then
    echo "Spark already Configured"
    exit 0
fi

touch /home/vagrant/.cspark
echo "Reconfigured Spark, This will format all Configuration"

# Edit Spark Environment
cd /usr/local/bin/spark
sudo cat /vagrant/resources/spark/env >> spark-env.sh;