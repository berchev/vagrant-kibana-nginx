#!/usr/bin/env bash

set -e

# Adding entry for nginx machine in /etc/hosts file
grep 'kibana' /etc/hosts &>/dev/null || {
  cp /etc/hosts /etc/hosts.bak
  echo '10.10.10.10   kibana   kibana' | sudo tee -a /etc/hosts
}

# Install apt-add-repository if not installed
which apt-add-repository || {
  apt-get update
  apt-get install -y software-properties-common
}

# add-apt-repository command is looking for library named "apt_pkg".
# I have different library and this is caused by different python version used by me.
[ -f "/usr/lib/python3/dist-packages/apt_pkg.so" ] || {
  cp /usr/lib/python3/dist-packages/apt_pkg\.*\.so /usr/lib/python3/dist-packages/apt_pkg.so
}

# Instaling packages needed for silent install Oracle JDK 8 on Ubuntu
apt-get update
apt-get install -y python-software-properties debconf-utils

# Java 8 Installation
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
apt-get install -y oracle-java8-installer

# add a GPG key to the apt sources keyring
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update


# Filebeat Instalation and setup
[ -d "/etc/filebeat" ] || {
  apt install filebeat -y
  mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
  cp /vagrant/conf/filebeat.yml /etc/filebeat/filebeat.yml
  systemctl start filebeat && systemctl enable filebeat
}

