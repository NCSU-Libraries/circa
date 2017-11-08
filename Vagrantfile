# -*- mode: ruby -*-
# vi: set ft=ruby :

vagrant_plugins = %w(vagrant-vbguest vagrant-triggers)
vagrant_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    puts "Plugin #{plugin} is not installed. Install it with:"
    puts "vagrant plugin install #{vagrant_plugins.join(' ')}"
    exit
  end
end

Vagrant.configure("2") do |config|
  # This box works better than the centos project created one
  config.vm.box = "geerlingguy/centos7"
  config.vm.box_version = "1.2.4"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.30"

  config.vm.synced_folder '.', '/vagrant'

  # Solr for Circa
  config.vm.network "forwarded_port", guest: 8983, host: 8983,
  auto_correct: true
  # archivesspace_backend_port
  config.vm.network "forwarded_port", guest: 8089, host: 8089,
    auto_correct: true
  # archivesspace_frontend_port
  config.vm.network "forwarded_port", guest: 8080, host: 8080,
    auto_correct: true
  # archivesspace public interface
  config.vm.network "forwarded_port", guest: 8081, host: 8081,
    auto_correct: true
  # archivesspace OAI-PMH server
  config.vm.network "forwarded_port", guest: 8082, host: 8082,
    auto_correct: true
  # archivesspace_solr_port
  config.vm.network "forwarded_port", guest: 8090, host: 8090,
    auto_correct: true
  # Circa
  config.vm.network "forwarded_port", guest: 3000, host: 3000,
    auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = 1024
    vb.cpus = 1
    # vb.gui = true
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = 'ansible/development-playbook.yml'
    ansible.inventory_path = 'ansible/development.ini'
    ansible.limit = 'all'
    # ansible.verbose = 'vvvv'
  end

  # https://github.com/kierate/vagrant-port-forwarding-info
  # vagrant plugin install vagrant-triggers
  # Get the port details in these cases:
  # - after "vagrant up" and "vagrant resume"
  config.trigger.after [:up, :resume] do
    run "#{File.dirname(__FILE__)}/get-ports.sh #{@machine.id}"
  end
  # - before "vagrant ssh"
  config.trigger.before :ssh do
    run "#{File.dirname(__FILE__)}/get-ports.sh #{@machine.id}"
  end

  # Until the patch in 1.8.6 is released do not try to insert ssh key. Or
  # manually apply the patch here:
  # https://github.com/mitchellh/vagrant/pull/7611
  # config.ssh.insert_key = false

  # set auto_update to false, if you do NOT want to check the correct
  # additions version when booting this machine
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = false

  config.ssh.forward_agent = true
end