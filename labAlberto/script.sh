#!/bin/bash

echo "instalando wget"
sudo yum install wget -y

echo "descargando ansible"
sudo wget https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.5.7-1.el7.ans.noarch.rpm

echo "instalando de manera local ansible"
sudo yum localinstall ansible-2.5.7-1.el7.ans.noarch.rpm -y

echo "check ansible version"
sudo ansible --version

echo "instalando playbook"
cd /vagrant/ansible && ansible-playbook -i inventory site-playbook.yml -k
