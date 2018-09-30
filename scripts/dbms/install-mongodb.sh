#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/vagrant/.mongo ]
then
    echo "MongoDB already installed."
    exit 0
fi

touch /home/vagrant/.mongo

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 2>&1

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confnew" install mongodb-org autoconf g++ make openssl libssl-dev libcurl4-openssl-dev pkg-config libsasl2-dev php-dev

sudo ufw allow 27017
sudo sed -i "s/bindIp: .*/bindIp: 0.0.0.0/" /etc/mongod.conf

sudo systemctl enable mongod
sudo systemctl start mongod

php_version="$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1,2,3)"

#Check PHP Version
if [ "$php_version" = "" ]; then
    sudo dpkg --configure -a
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-get -y update
    sudo apt-get -y install php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip 
    php_version="7.0"
fi

if [ "$php_version" = "5.6" ]; then
    sudo apt-get install -y php5.6-mongodb
    sudo service php5.6-fpm restart
elif [ "$php_version" = "7.0" ]; then
    sudo apt-get install -y php7.0-mongodb
    sudo service php7.0-fpm restart
elif [ "$php_version" = "7.1" ]; then
    sudo apt-get install -y php7.1-mongodb
    sudo service php7.1-fpm restart
elif [ "$php_version" = "7.2" ]; then
    sudo apt-get install -y php7.2-mongodb
    sudo service php7.2-fpm restart
fi

mongo admin --eval "db.createUser({user:'carbonifero',pwd:'secret',roles:['root']})"