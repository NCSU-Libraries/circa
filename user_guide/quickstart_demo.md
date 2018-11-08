# Circa Demo Vagrant Box

## Prerequisites
1. **Vagrant** - Vagrant is available for all operating systems and instructions for installing vagrant can be found here: https://www.vagrantup.com/downloads.html
2. **Virtualbox** - Virtalbox is required for management of the vagrant machines. Virtualbox can be downloaded at https://www.virtualbox.org/wiki/Downloads
   **Important Note About VirtualBox and OSX 10.13 (High Sierra)** There is a known error with the compatibility of VirtualBox and OSX 10.13. This will cause the Vagrant provisioning to fail. You must give VirtualBox additional permissions to run using the following steps.
      1. Open System Preferences
      2. Click on Security & Privacy
      3. If you see a sentence that reads "System software from developer... was blocked from loading" click the 'allow' button next to it
2. **ArchivesSpace** - Circa requires an ArchivesSpace installation with the following additional requirements
   1. the archivesspace-component-uri-display-plugin that is found here: https://github.com/NCSU-Libraries/archivesspace-component-uri-display-plugin must be installed and enabled on your ArchivesSpace installation. For testing purposes it is okay if this is installed on just staging - if that is the instance of ArchivesSpace that you will be using for the demo.
   2. ArchivesSpace username/password. The Circa demo will retrieve resource URIs from ArchiveSpace which requires a username and password.

## Quick Start

1. Make sure you have installed Vagrant and VirtualBox
2. Install the vbguest Vagrant plugin by running the command `vagrant plugin install vagrant-vbguest` from your terminal application
3. Run  `git clone git@github.com:NCSU-Libraries/circa.git` from your terminal to clone the Circa GitHub repo
4. run cd circa`
5. Create a copy of the file config/application_example.yml and name it application.yml (keeping it in the config folder)
6. Create a copy of the file config/database-sqlite3.yml and name to database.yml (keeping it in the config folder)
7. Update application.yml with the information needed to connect with your ArchivesSpace installation

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
8. From your terminal run `vagrant up`
   1. This will import the vagrant box, boot up and run the ansible provisioner which installs all of the necessary application components - it may take a little while for this process to complete. **At the end of the process you will see 1 failed task - this is expected.**

9. From your terminal run `vagrant provision`
10. run `vagrant ssh` to ssh into the newly created virtual machine
11. run `cd /vagrant` to change into the application root folder
12. run `rails s -b 0.0.0.0`
13. in your browser go to localhost:3000
14. login using admin@circa as the username and  circa_admin as the password
15. click on locations > create new location
    1. Give it a name and click create location
