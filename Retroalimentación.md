# Retroalimentación

- Relación de Confianza
- Vagrant Aprovisionamiento 
- Ansible Modules 

1. Relación de Confianza (cómo ejecutar ssh-keygen sin aviso?)

Automatizando la generación de clave privada 
```
su - vagrant -c "ssh-keygen -q -t rsa -N '' -f /home/vagrant/.ssh/id_rsa"
```
  -N                            new_passphrase proporciona la nueva frase de contraseña.
  -q                            silenciar ssh-keygen.
  -f filename                   Evita ingresar el uso de la clave, especifica el nombre de archivo del archivo de clave.
  su - vagrant -c               especifica con que usuario ejecutara el comando en este caso el usuario es "vagrant"
  /home/vagrant/.ssh/id_rsa     la ruta donde almacenaremos nuestra llave publica

2. Aprovisionamiento Vagrant 

Lo que haremos es guardar los comandos que se deben ejecutar durante el arranque de nuestra máquina en un script. Este proceso automático es lo que se conoce como ‘aprovisionamiento’. En este caso lo haremos directamente en el Vagrantfile y con el aprovisionamiento "SHELL"

Vagrant soporta diferentes herramientas de configuración, como por ejemplo:

Shell scripts
Puppet
Ansible
Chef

```
 node.vm.provision "shell", inline: <<-SHELL
            echo "instalando wget"
            sudo yum install wget -y

            echo "descargando ansible"
            sudo wget https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.5.7-1.el7.ans.noarch.rpm    

            echo "instalando de manera local ansible"
            sudo yum localinstall ansible-2.5.7-1.el7.ans.noarch.rpm -y

            echo "check ansible version"
            sudo ansible --version

```
Como explicamos anteriormente usaremos el aprovisionamiento SHELL dentro de nuestro Vagrantfile para ejecutar y automatizar la tarea de instalar Ansible en nuestro nodo "bastion" esto para que nosotros no tengamos que hacer nada.

3. Modulos de Ansible, en este laboratorio usaremos.

- Copy
- Shell
- Authorized Keys
- Yum
- Service
- Systemd

A continuación una breve definición de cada uno y un ejemplo para ver en que caso usaremos en nuestro laboratorio.

- Copy ._ El "Copy" copia un archivo de la máquina local o remota a una ubicación en la máquina remota.
```
- name: Copiar elasticsearch.repo 
  become: yes
  copy:
        src: elasticsearch.repo
        dest: /etc/yum.repos.d/elasticsearch.repo
        mode: '0644'
        owner: root
        group: root

Copiar archivo con dueño y permisos "root"
```
- Shell ._ El "Shell" toma el nombre del comando seguido de una lista de argumentos delimitados por espacios.
```
- name: Descargamos e instalamos elastic
  shell: wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.1-x86_64.rpm 

Usamos Shell para descargar el rpm de elasticsearch con  el argumento "wget"
```
- Authorized Keys ._ Agrega o elimina claves SSH autorizadas para cuentas de usuario particulares.
```
- name: Set up multiple authorized keys
  authorized_key:
    user: vagrant
    state: present
    key: '{{ item }}'
  with_file:
    - keyvm4

Configura la llave privada que previamente generaremos *(cómo ejecutar ssh-keygen sin aviso?)* revisar punto 1 ,  una vez generada se guarda como item "keyvm4" y esta llave se configura de manera automatica en los nodos restantes en la ruta .ssh/authorizedkeys
```
- Yum ._ Instala, actualiza, elimina y enumera paquetes y grupos con el administrador de paquetes yum.
```
- name: Install elastic
  yum:
    name: elasticsearch-7.17.1-x86_64
    state: present

Usamos el modulo de Yum para descargar elasticsearch puesto que nuestra distribución es Centos y podremos realizar la gestion gracias a este modulo.
```
- Service ._ Controla servicios en hosts remotos.
```
- name: Enable el servicio de Elasticsearch
  become: yes
  service:
        name: elasticsearch.service
        state: restarted

En este caso se utiliza el modulo service para reiniciar el servicio de elasticsearch.service
```