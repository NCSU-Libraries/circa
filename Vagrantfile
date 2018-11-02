# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "circa"
  config.ssh.forward_agent = "true"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.30"

  # Solr for Circa
  config.vm.network "forwarded_port", guest: 8983, host: 8983,
  auto_correct: true
  # Circa
  config.vm.network "forwarded_port", guest: 3000, host: 3000,
    auto_correct: true

  ##Additional ArchiveSpace Ports if installing ArchiveSpace on your VM
  # archivesspace_backend_port
  # config.vm.network "forwarded_port", guest: 8089, host: 8089,
  #   auto_correct: true
  # # archivesspace_frontend_port
  # config.vm.network "forwarded_port", guest: 8080, host: 8080,
  #   auto_correct: true
  # # archivesspace public interface
  # config.vm.network "forwarded_port", guest: 8081, host: 8081,
  #   auto_correct: true
  # # archivesspace OAI-PMH server
  # config.vm.network "forwarded_port", guest: 8082, host: 8082,
  #   auto_correct: true
  # # archivesspace_solr_port
  # config.vm.network "forwarded_port", guest: 8090, host: 8090,
  #   auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = 1024
    vb.cpus = 1
  end

  #ansible provisioning
  config.vm.provision "ansible_local" do |ansible|
    ansible.verbose = 'v'
    ansible.provisioning_path = '/vagrant/ansible'
    ansible.playbook = 'development-playbook.yml'
    ansible.inventory_path = 'development.ini'
    ansible.limit = 'all'
  end
end
