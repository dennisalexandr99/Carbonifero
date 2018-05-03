#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.host ]
then
    echo "POX Controller already installed."
    exit 0
fi

touch /home/vagrant/.host

IFS='.' read -r -a array <<< $1
sudo su
echo "# Cofigure by Vagrant < Carbonifero >" >> /etc/hosts
for i in {1..3};
do
    echo "${array[0]}.${array[1]}.${array[2]}.$((${array[3]}+$i))  carbonifero-$i" >> /etc/hosts;
done