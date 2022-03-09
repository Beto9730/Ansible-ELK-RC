# Ansible-ELK-RC
Ansible+ELK+RelacionConfianza

1. Primero realizamos vagrant up + provision, esto para que cree nuestras maquinas virtuales con las configuraciones echas en nuestro Vagranfile
```
vagrant up --provision
```
4. Nos dirijimos a /vagrant/ansible y ejecutamos en playbook
```
ansible-playbook -i inventory site-playbook.yml
```


