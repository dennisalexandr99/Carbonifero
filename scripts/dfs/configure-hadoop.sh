#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.chadoop ]
then
    echo "Hadoop already Configured"
    exit 0
fi

touch /home/vagrant/.chadoop
echo "Reconfigured Hadoop, This will format all Data"

cd /usr/local/bin/hadoop
# Make Directory for Namenode and DataNode
sudo rm hadoop2_data/hdfs -rf
sudo mkdir -p hadoop2_data/hdfs/namenode
sudo mkdir -p hadoop2_data/hdfs/datanode
sudo mkdir -p hadoop2_data/hdfs/temp
sudo mkdir -p logs
sudo chown vagrant -R /usr/local/bin/hadoop
sudo chmod 777 -R logs hadoop2_data

# Edit Hadoop Environment
cd etc/hadoop
sudo cat /vagrant/resources/hadoop/env >> hadoop-env.sh;

# Edit Core Site XML
sudo cp /vagrant/resources/hadoop/core-site core-site.xml -f

# Edit HDFS Site XML
numNodes=$1+1
divider=$2
numReplica=$((numNodes / divider))

if [ "$numReplica" = "0" ]; then
    numReplica=1
fi

sudo cp /vagrant/resources/hadoop/hdfs-site hdfs-site.xml -f
sudo sed -i -e s/HADOOP_REPLICATION/$numReplica/ hdfs-site.xml

# Edit Mapred Site XML
sudo cp /vagrant/resources/hadoop/mapred-site mapred-site.xml -f

# Edit Yarn Site XML
sudo cp /vagrant/resources/hadoop/yarn-site yarn-site.xml -f

# Create Master and Slave
# Master
for ((i=1;i<=numReplica;i++));
do
    sudo echo "carbonifero-$i" >| masters;
done

# Slave
for ((i=1;i<numNodes;i++));
do
    sudo echo "carbonifero-$i" >| slaves;
done

# Format Namenode
if [ "$3" = "1" ]; then
    /usr/local/bin/hadoop/sbin/stop-dfs.sh 2>/dev/null
    /usr/local/bin/hadoop/sbin/stop-yarn.sh 2>/dev/null
    sudo rm /usr/local/bin/hadoop/hadoop2_data/hdfs/namenode/current -fr
    echo 'Y' | /usr/local/bin/hadoop/bin/hdfs namenode -format 2>/dev/null
    /usr/local/bin/hadoop/sbin/start-dfs.sh 2>/dev/null
    /usr/local/bin/hadoop/sbin/start-yarn.sh 2>/dev/null
fi