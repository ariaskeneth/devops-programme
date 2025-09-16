# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"

  # Port forwarding: host -> guest
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true

  # Rete privata opzionale (commenta se non serve)
  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "fondamenta-devops"
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell", path: "provision.sh"
end