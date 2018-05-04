#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.chost ]
then
    echo "Host already Configured"
    exit 0
fi

touch /home/vagrant/.chost

IFS='.' read -r -a array <<< $1
numNodes=$2
sudo su
echo "# Cofigure by Vagrant < Carbonifero >" >> /etc/hosts
for ((i=1;i<=numNodes;i++));
do
    if [ "$i" = "1" ]; then
        echo "${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+$i))  carbonifero-$i master" >> /etc/hosts;
    else
        echo "${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+$i))  carbonifero-$i slave-$i" >> /etc/hosts;
    fi
done