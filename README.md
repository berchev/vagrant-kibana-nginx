# vagrant-kibana-nginx

## Description
Downloading this project you will have elastic stack working environment(filebeat, logstash, elastic search, kibana) on two servers: NGINX SERVER and KIBANA SERVER.

The goal is to send nginx logs to kibana tool. Picture below will give you better overview what this project includes:

![](https://github.com/berchev/vagrant-kibana-nginx/blob/master/images/servers_diagram.png)

## Requirements
- All instructions are tested on Ubuntu 18.04
- Vagrant installed
- Virtualbox installed
- System with not less than 4 GB RAM 

## Files
- `images/ directory` - contain images used into README.md file
- `conf/filebeat.yml` - filebeat configuration file used for collecting logs from NGINX SERVER and send it to logstash
- `conf/nginx.conf` - logstash pipeline configuration which purpose is to send parsed logs from filebeat to elastic search
- `conf/logstash_process.service` - unit file which makes logstash to use conf/nginx.conf file
- `scripts/kibana_provision.sh` - script for provisioning KIBANA SERVER
- `scripts/nginx_provision.sh` - script for provisioning NGINX SERVER

## Guide on HOW to run all this to your PC
- If Virtualbox is not installed: [install virtualbox](https://www.virtualbox.org/wiki/Downloads) 
- If Vagrant is not installed: [Install Vagrant](https://www.vagrantup.com/docs/installation/)
- Download this repo content: `https://github.com/berchev/vagrant-kibana-nginx.git`
- Change to vagrant-kibana-nginx directory: `cd vagrant-kibana-nginx`
- Type: `vagrant up` and wait the script to finish
- Now you have 2 virtual machines NGINX and KIBANA
- Open browser in your host machine type: `localhost:8080` in order to generate some nginx logs. Repeat few times. (Port 80 from NGINX is forwarded to port 8080 on your machine)
- Open new browser tab and type: `localhost:56011` (Port 5601 from KIBANA is forwarded to port 56011 on your machine)
- You will see following:

![](https://github.com/berchev/vagrant-kibana-nginx/blob/master/images/kibana1.png)

![](https://github.com/berchev/vagrant-kibana-nginx/blob/master/images/kibana2.png)

![](https://github.com/berchev/vagrant-kibana-nginx/blob/master/images/kibana3.png)

## In addition
- if you need to connect to KIBANA for any reason: `vagrant ssh kibana`
- if you need to connect to NGINX for any reason: `vagrant ssh nginx`
- if you need to turn off machine:`vagrant halt kibana` or `vagrant halt nginx`
- to delete created machines: `vagrant destroy`

## TODO
