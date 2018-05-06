#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
# Check If Maria Has Been Installed

if [ -f /home/vagrant/.maria ]
then
    echo "MariaDB already installed."
    exit 0
fi

touch /home/vagrant/.maria

sudo dpkg --configure -a
cd ~

# Remove MySQL

sudo apt-get remove -y --purge mysql-server mysql-client mysql-common
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo dpkg --configure -a

sudo rm -rf /var/lib/mysql
sudo rm -rf /var/log/mysql
sudo rm -rf /etc/mysql

# Add Maria PPA

sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.osuosl.org/pub/mariadb/repo/10.2/ubuntu xenial main'
sudo apt-get update

# Set The Automated Root Password

export DEBIAN_FRONTEND=noninteractive

sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/data-dir select ''"
sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password password secret"
sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password_again password secret"

# Install MariaDB

sudo apt-get install -y mariadb-server

# Configure Maria Remote Access

sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo service mysql restart

sudo mysql --user="root" --password="secret" -e "CREATE USER 'carbonifero'@'0.0.0.0' IDENTIFIED BY 'secret';"
sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'carbonifero'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'carbonifero'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
sudo service mysql restart
