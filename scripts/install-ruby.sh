#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.ruby ]
then
    echo "Ruby already Installed"
    exit 0
fi

touch /home/vagrant/.ruby

sudo dpkg --configure -a
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
sudo \curl -sSL https://get.rvm.io -o rvm.sh
sudo source ~/.rvm/scripts/rvm
sudo rvm install ruby --default