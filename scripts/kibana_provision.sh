#!/usr/bin/env bash
set -e

# Adding entry for nginx machine in /etc/hosts file
grep 'nginx' /etc/hosts &>/dev/null || {
  cp /etc/hosts /etc/hosts.bak
  echo '10.10.10.11   nginx   nginx' | sudo tee -a /etc/hosts
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

# Elasticsearch Installation
[ -d "/etc/elasticsearch" ] || {
  apt-get -y install elasticsearch
  cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak
  sed -i "/^#http.port: 9200/s/^#*//" /etc/elasticsearch/elasticsearch.yml
  sed -i 's/#network.host: 192.168.0.1/network.host: ["localhost","10.10.10.10"]/' /etc/elasticsearch/elasticsearch.yml
  systemctl enable elasticsearch && systemctl start elasticsearch
}

# Kibana Installation and setup
[ -d "/etc/kibana" ] || {
  apt-get install -y kibana
  cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak
  echo 'server.port: 5601' | sudo tee -a /etc/kibana/kibana.yml
  echo 'server.host: "0.0.0.0"' | sudo tee -a /etc/kibana/kibana.yml
  echo 'elasticsearch.url: "http://localhost:9200"' | sudo tee -a /etc/kibana/kibana.yml
  echo 'logging.dest: /var/log/kibana' | sudo tee -a /etc/kibana/kibana.yml
  touch /var/log/kibana 
  chmod 666 /var/log/kibana
  systemctl enable kibana && systemctl start kibana
}

# Filebeat Instalation and setup
#[ -d "/etc/filebeat"] || {
#  apt install filebeat -y
#  mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
#  cp /vagrant/conf/filebeat.yml /etc/filebeat/filebeat.yml
  #cp /vagrant/conf/filebeat.yml /etc/filebeat/modules.d/nginx.yml
#  systemctl start filebeat && systemctl enable filebeat
#}

# Install and configure logstash + GeoIP
[ -d "/etc/logstash" ] || {
  apt-get install -y logstash
  cp /etc/logstash/logstash.yml /etc/logstash/logstash.yml.bak
  echo 'path.data: /var/lib/logstash' | sudo tee -a /etc/logstash/logstash.yml
  echo 'path.config: /etc/logstash/conf.d' | sudo tee -a /etc/logstash/logstash.yml
  echo 'path.logs: /var/log/logstash' | sudo tee -a /etc/logstash/logstash.yml
  cp /vagrant/conf/nginx.conf /etc/logstash/conf.d/
  wget -P /etc/logstash/ http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
  gunzip /etc/logstash/GeoLite2-City.mmdb.gz
  systemctl start logstash && systemctl enable logstash
}

# Start gathering data with logstash, based on /etc/logstash/conf.d/nginx.conf
chmod +x /vagrant/conf/logstash_process.service
cp /vagrant/conf/logstash_process.service /etc/systemd/system/
systemctl start logstash_process.service && systemctl enable logstash_process.service

