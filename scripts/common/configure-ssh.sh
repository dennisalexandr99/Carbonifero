#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.cssh ]
then
    echo "SSH already Configured"
    exit 0
fi

touch /home/vagrant/.cssh

if [ ! "$1" = "1" ]; then
    exit 0
fi

numNodes=$2

connect_ssh () {
    ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $1
}

# Connecting
for ((i=1;i<=numNodes;i++));
do
    connect_ssh "carbonifero-$i"

    if [ "$i" = "1" ]; then
        connect_ssh "master"
    fi
done

connect_ssh "0.0.0.0"
connect_ssh "127.0.0.1"