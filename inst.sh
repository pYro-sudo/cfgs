#!/bin/bash

mkdir -p /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -kL 'https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub'
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys

echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

echo 'export PATH=$PATH:/usr/local/bin' >> /home/vagrant/.bashrc