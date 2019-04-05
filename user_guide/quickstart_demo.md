# Circa Demo & Development with Vagrant

## Prerequisites
1. [Vagrant](https://www.vagrantup.com/downloads.html)
1. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Circa requires an [ArchivesSpace](https://archivesspace.org/) installation with the following additional requirements:
   
   a. The [archivesspace-component-uri-display-plugin](https://github.com/NCSU-Libraries/archivesspace-component-uri-display-plugin) must be installed and enabled on your ArchivesSpace installation.
   
   b. ArchivesSpace username and password. The Circa demo will retrieve resource URIs from ArchiveSpace which requires a username and password. This should be a new account that is just used for Circa. It requires read access to all ArchivesSpace resources.

## Quick Start
### Installation

Verify the prerequisites listed above. 

Check out the code and change directories:

```sh
git clone git@github.com:NCSU-Libraries/circa.git
cd circa
```

Copy config/application_example.yml to config/application.yml:

```sh
cp config/application_example.yml config/application.yml
```

Update config/application.yml with the appropriate [ArchiveSpace connection parameters](https://github.com/NCSU-Libraries/circa#archivesspace-connection-parameters). 

Start Vagrant:

```sh
vagrant up
```

SSH to Vagrant machine and start Rails:

```sh
vagrant ssh
cd /vagrant
bundle exec rails s -b 0.0.0.0
```

View Circa in your browser on the host machine at [localhost:3000](http://localhost:3000).

Log in using the username **admin@circa** and the password **circa_admin**.
