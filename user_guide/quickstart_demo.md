# Circa Demo Vagrant Box

Follow these steps to get a vagrant box demo of Circa up and running.

## Prerequisites
1. Vagrant - vagrant is available for all operating systems and instructions for installing vagrant can be found here: https://www.vagrantup.com/downloads.html
2. ArchivesSpace - Circa requires an ArchivesSpace installation with the following additional requirements
   1. the archivesspace-component-uri-display-plugin that is found here: https://github.com/NCSU-Libraries/archivesspace-component-uri-display-plugin must be installed and enabled on your ArchivesSpace installation. For testing purposes it is okay if this is installed on just staging - if that is the instance of ArchivesSpace that you will be using for the demo.
   2. ArchivesSpace username/password. The Circa demo will retrieve resource URIs from ArchiveSpace which requires a username and password.

## Quick Start

1. Open your terminal application and `run git clone git@github.com:NCSU-Libraries/circa.git`
2. run cd circa
3. Create a copy of the file config/application_example.yml and name it application.yml (keeping it in the config folder)
4. Create a copy of the file config/database-sqlite3.yml and name to database.yml (keeping it in the config folder)
5. Update application.yml with the information needed to connect with your ArchivesSpace installation

     * **archivesspace_host** (ex. *archivespace.yourhost.org*)<br>
     The host name for the ArchivesSpace instance.
     This option should be used for the 'default' ArchivesSpace deployment scenario,
     with each component sharing a host but served on different ports.

     * **archivesspace_backend_host** (ex. *api.archivespace.yourhost.org*)<br>
     The hostname for the ArchivesSpace backend (API).
     Use this option if the backend uses an unique host name. If present, this value
     will override **archivesspace_host**

     * **archivesspace_frontend_host** (ex. *staff.archivespace.yourhost.org*)<br>
     The hostname for the ArchivesSpace frontend (staff interface).
     Use this option if the frontend uses an unique host name. If present, this value
     will override **archivesspace_host**

     * **archivesspace_username**: User name used to connect to ArchivesSpace.
     User should have read access to all resources.

     * **archivesspace_password**: Password associated with archivesspace_username

     * **archivesspace_https**: To force connections via https, set this to '1',
     otherwise leave it out.

6. From your terminal run `vagrant up`
   1. This will import the vagrant box, boot up and run the ansible provisioner which installs all of the necessary application components - it may take a little while for this process to complete
7. From your terminal run `vagrant provision`
8. run `vagrant ssh` to ssh into the newly created virtual machine
9. run `cd /vagrant` to change into the application root folder
10. run `rails s -b 0.0.0.0`
11. in your browser go to localhost:3000
12. login using admin@circa as the username and  circa_admin as the password
13. click on locations > create new location
    1. Give it a name and click create location
