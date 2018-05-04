#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

cd /usr/local/bin/hadoop-2.7.3

# Make Directory for Namenode and DataNode
sudo mkdir -p hadoop2_data/hdfs/namenode
sudo mkdir -p hadoop2_data/hdfs/datanode
sudo mkdir -p hadoop2_data/hdfs/temp
sudo mkdir -p logs
sudo chown vagrant -R /usr/local/bin/hadoop-2.7.3
sudo chmod 777 -R logs hadoop2_data

# Edit Hadoop Environment
cd etc/hadoop
sudo echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle/" >> hadoop-env.sh;

# Edit Core Site XML
sudo cp /vagrant/resources/hadoop/core-site core-site.xml -f

# Edit HDFS Site XML
numNodes=$1
divider=1
numReplica=$((numNodes / divider))
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
    echo "carbonifero-$i" >| masters;
done

# Slave
for ((i=1;i<=numNodes;i++));
do
    echo "carbonifero-$i" >| slaves;
done