Vagrant.configure("2") do |config|
  config.vm.define vm_name="kibana" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
    node.vm.box = "berchev/xenial64"
    node.vm.hostname = "kibana"
    node.vm.network "private_network", ip: "10.10.10.10"
    node.vm.network "forwarded_port", guest: 5601, host: 56011
    node.vm.provision "shell", path: "scripts/kibana_provision.sh"
  end
  

  config.vm.define vm_name="nginx" do |node|
#    node.vm.provider "virtualbox" do |vb|
#      vb.memory = "1024"
#    end
    node.vm.box = "berchev/nginx64"
    node.vm.hostname = "nginx"
    node.vm.network "private_network", ip: "10.10.10.11"
    node.vm.network "forwarded_port", guest: 80, host: 8080
    node.vm.provision "shell", path: "scripts/nginx_provision.sh"
  end 
 
end
