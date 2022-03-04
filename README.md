# Ansible-ELK-RC
Ansible+ELK+RelacionConfianza


1. Primero realizamos vagrant up + provision, esto para que cree nuestras maquinas virtuales con las configuraciones echas en nuestro Vagranfile
```
vagrant up --provision
```
2. Se genera llave publica de la vm4 que sera nuestro bastion y la distribuiremos en todas los nodos
```
-Ingresamos al bastion
vagrant ssh vm4

-Generamos la llave publica , presionamos 3 enters
ssh-keygen 

-Validamos la llave publica generada en la siguiente ruta 
cat /home/vagrant/.ssh/id_rsa.pub
```
3. Copiamos la llave publica al "files" de bastion-ELK con el nombre "keyvm4"
```
En caso ya exista una llave, la reemplazamos con la actual
```
4. Agregamos los nodos a establecer la confianza para que nuestro bastion los reconozca
```
ssh vagrant@10.0.0.11
ssh vagrant@10.0.0.12
ssh vagrant@10.0.0.13 

Nos pregunta si estamos seguro de conectarnos, ponemos "yes" y colocamos la clave en este caso es: "vagrant"

NOTA: Luego de este paso nos conectaremos al nodo, tendremos que salir con "exit" para replicar el paso en los nodos restantes desde el bastion
```
5. Nos dirijimos a /vagrant/ansible y ejecutamos en playbook
```
ansible-playbook -i inventory site-playbook.yml -k
```


