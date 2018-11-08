# Circa Demo Vagrant Box

## Prerequisites
1. **Vagrant** - Vagrant is available for all operating systems and instructions for installing vagrant can be found here: https://www.vagrantup.com/downloads.html
2. **Virtualbox** - Virtalbox is required for management of the vagrant machines. Virtualbox can be downloaded at https://www.virtualbox.org/wiki/Downloads
   
   > **Important Note About VirtualBox and OSX 10.13 (High Sierra)** There is a known error with the compatibility of VirtualBox and a security setting in OSX 10.13. You must give VirtualBox additional permissions to run using the following steps.
   >   1. Open System Preferences
   >   2. Click on Security & Privacy
   >   3. If you see a sentence that reads "System software from developer... was blocked from loading" click the 'allow' button next to it
   
2. **ArchivesSpace** - Circa requires an ArchivesSpace installation with the following additional requirements
   1. the archivesspace-component-uri-display-plugin that is found here: https://github.com/NCSU-Libraries/archivesspace-component-uri-display-plugin must be installed and enabled on your ArchivesSpace installation. For testing purposes it is okay if this is installed on just staging - if that is the instance of ArchivesSpace that you will be using for the demo.
   2. ArchivesSpace username/password. The Circa demo will retrieve resource URIs from ArchiveSpace which requires a username and password.

## Quick Start
### Installation

1. Make sure you have installed Vagrant and VirtualBox
2. Install the vbguest Vagrant plugin by running the command `vagrant plugin install vagrant-vbguest` from your terminal application.
3. Clone the Circa repository to your local machine by running `git clone git@github.com:NCSU-Libraries/circa.git`or download and unzip from https://github.com/ncsu-libraries/circa.
4. Run `cd circa`.
5. Rename application_example.yml to application.yml in the config directory. 
6. Rename database-sqlite3.yml to database.yml in the config directory. 
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
     
8. From your terminal `cd` into the Circa directory and run `vagrant up`
   > This will import the correct base VM, boot up, and run the ansible provisioner that installs all of the necessary application components. This process will take a few minutes to complete.
   >
   > **At the end of the process you will see 1 failed task - this is expected.**

9. From your terminal run `vagrant provision`
10. Run `vagrant ssh` to ssh into the newly created virtual machine
11. Run `cd /vagrant` to change into the application root folder
12. Run `rails s -b 0.0.0.0` to start the application
13. In your browser go to localhost:3000
14. Log in using the username **admin@circa** and the password **circa_admin**
