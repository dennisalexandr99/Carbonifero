# Carbonifero
Vagrant Setup for Server Administration

## Requirement
- Vagrant v.1.9.0
- Virtual Machines (VirtualBox)
- 20 GB Storage

## Specification
### Default OS 
- Ubuntu Server 16.04

### PORT
- 80 => 8000
- 443 => 44300
- 3306 => 33060
- 4040 => 4040
- 5432 => 54320
- 8025 => 8025
- 27017 => 27017
### Installed Apps 
- Language Pack En Base
- APT Transport Https
- Software Properties Common

### Available Apps
### DBMS
- Mongo
- MariaDB

### Programming Language
- PHP (5.6, 7.0, 7.1, 7.2)
- Java 8.0
- NodeJS
- Ruby

## Installation
First you must clone this repository

`$ git clone https://github.com/riyadh11/Carbonifero.git`
    
Then move your default folder to Carbonifero directory

`$ cd Carbonifero`

Next Copy Carbonifero.yaml.example to Carbonifero.yaml

`$ cp Carbonifero.yaml.example Carbonifero.yaml`

After that, configure your Carbonifero configuration. Setting that can be customized are cpu core, ram, memory, os, ip and apps

Example :   
	
    ip: "192.168.10.12"
    
	memory: 1024
    
	cpus: 1
    
	provider: virtualbox
    
	authorize: ~/.ssh/id_rsa.pub
    
	keys:
        - ~/.ssh/id_rsa
    
	folders:
        - map: D:/projects
          to: /home/vagrant/projects
		  
    dbms:
		- mongodb
    
	languages:
		- java
		
	databases:
		- carbonifero
    
Fire Up Vagrant

`$ vagrant up`

Voila.

## Security
If you discover any security related issues, please email ahmad.riyadh.al@faathin.com instead of using the issue tracker.

## Credits
- [https://www.canonical.com](Canonical Ltd)

## License
The Apache License 2.0 License. Please see [License File](LICENSE.md) for more information.
