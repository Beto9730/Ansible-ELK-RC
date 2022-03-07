# Ansible-ELK-RC
Ansible+ELK+RelacionConfianza

1. Primero realizamos vagrant up + provision, esto para que cree nuestras maquinas virtuales con las configuraciones echas en nuestro Vagranfile
```
vagrant up --provision
```
2. Copiamos la llave publica al "files" de bastion-ELK con el nombre "keyvm4"
```
La buscamos en el directorio cat /home/vagrant/.ssh/id_rsa.pub
En caso ya exista una llave, la reemplazamos con la actual en el "files" de bastion-ELK con el nombre "keyvm4"
```
3. Agregamos los nodos a establecer la confianza para que nuestro bastion los reconozca
```
ssh vagrant@10.0.0.11
ssh vagrant@10.0.0.12
ssh vagrant@10.0.0.13 

Nos pregunta si estamos seguro de conectarnos, ponemos "yes" y colocamos la clave en este caso es: "vagrant"

NOTA: Luego de este paso nos conectaremos al nodo, tendremos que salir con "exit" para replicar el paso en los nodos restantes desde el bastion
```
4. Nos dirijimos a /vagrant/ansible y ejecutamos en playbook
```
ansible-playbook -i inventory site-playbook.yml -k
```


