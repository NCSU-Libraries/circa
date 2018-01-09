# Quick start

## Vagrant

Development is done in Vagrant. You will need to have [Vagrant](https://www.vagrantup.com/) installed.

Check out the code:

```sh
git clone git@github.com:NCSU-Libraries/circa.git
cd circa
```

Start vagrant:

```sh
vagrant plugin install vagrant-vbguest vagrant-triggers
vagrant up
```

While this is installing the appropriate box and provisioning it, you can look through the /ansible directory to get some idea of all the dependencies and how the application gets deployed to a production environment.

After finished provisioning the box, ssh to the box, go to `/vagrant` directory and start the server.
```sh
vagrant ssh
cd /vagrant
rails server -b 0.0.0.0
```
