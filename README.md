# Ansible-ELK-RC
Ansible+ELK+RelacionConfianza

### Introducción

En este laboratorio instalaremos ELK en 3 nodos diferentes usando un cuarto nodo como nuestro Bastión y donde se ejecutara todas las tareas.

Herramientas usadas:

- Ansible 
- Vagrant

1. Primero realizaremos vagrant up + provision, esto para que cree nuestras maquinas virtuales con las configuraciones echas en nuestro Vagrantfile
```
vagrant up --provision
```
*NOTA:* una vez nuestro laboratorio haya desplegado tendremos que ingresar a la interfaz de "Kibana" a traves del siguiente link: localhost:5601.Luego de esto realizar los siguientes pasos: 

- Nos dirigimos a “Management” y escribimos el nombre de nuestro índice en la sección “Index pattern”
- Establecemos “syslog-*” para que de esa forma agrupe todos los índices con el nombre de “syslog” sin importar la fecha de creación.
- Damos clic al botón “Next step”, y en la siguiente vista nos pedirá un filtro de fecha y hora.
- Seleccionamos “@timestamp”. Y finalizamos con “Create index pattern”
- Ahora nos dirigimos a la sección de “Discover” y podemos observar todos nuestros registros insertados.

Esta configuración fue realizada para el monitoreo de log de forma local; por otra parte, podemos configurar un agente en cada servidor cliente, para que inicie el envió de sus logs al Logstash o Elasticsearch, y de esa forma tener un ambiente centralizado de Logs.

2. En nuestro Vagrantfile tenemos toda la configuración de todas nuestras maquinas virtuales y los comandos a ejecutar. En primer lugar observamos:

- Vagrant.configure(2) do |config| = Configuracion de Vagrant 
- VM_NUMBER = Número de maquinas virtuales
- DISK_NUMBER = Número de discos que tendra cada maquina virtual
-  (1..VM_NUMBER).each do |i| = Un bucle de las maquinas que creera empezando con la vm1 con la ip priv: 10.0.0.11 y asi sucesivamente hasta llegar a la ultima vm4 con la ip priv: 10.0.0.14.
```
Vagrant.configure(2) do |config|
#### CUANTAS MAQUINAS VIRTUALES QUIERES CREAR?
VM_NUMBER=4
#### CUANTOS DISCOS QUIERES QUE TENGA CADA VM?
DISK_NUMBER=0
  (1..VM_NUMBER).each do |i|
    config.vm.define "vm#{i}" do |node|
        node.vm.box = "centos/7"
        node.vm.hostname = "vm#{i}"
        node.vm.network :private_network, ip: "10.0.0.1#{i}"
```
3. Aquí observamos condiciones que se les da a ciertas maquinas en concreto validamos en este caso que las condiciones se aplican a la maquina vm1, vm2 y vm4.

-  if i==3 = Observamos que aqui forwardea el puerto 5601 para la maquina vm3 que es donde instalaremos Kibana
          node.vm.network "forwarded_port", guest: 5601, host: 5601
        end
        if i==1
          node.vm.network "forwarded_port", guest: 80, host: "80"
        end
-  if i==2 = La memoria para la vm2 en este caso seria de 1500 y de las demas 350, en la vm2 instalaremos Elasticsearch
          vb.memory = "1500"
        else
          vb.memory = "350"
        end
-  if i==4 = Usaremos aprovisionamiento de Vagrant que es donde ejecutaremos comandos shell en la vm4 que sera nuestro Bastion-ELK 
          node.vm.provision "shell", inline: <<-SHELL
            echo "instalando wget"
            sudo yum install wget -y

            echo "descargando ansible"
            sudo wget https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.5.7-1.el7.ans.noarch.rpm    

            echo "instalando de manera local ansible"
            sudo yum localinstall ansible-2.5.7-1.el7.ans.noarch.rpm -y

```
        if i==3
          node.vm.network "forwarded_port", guest: 5601, host: 5601
        end
        if i==1
          node.vm.network "forwarded_port", guest: 80, host: "80"
        end
          node.vm.provider "virtualbox" do |vb|
        if i==2
          vb.memory = "1500"
        else
          vb.memory = "350"
        end
        if i==4
          node.vm.provision "shell", inline: <<-SHELL
            echo "instalando wget"
            sudo yum install wget -y

            echo "descargando ansible"
            sudo wget https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.5.7-1.el7.ans.noarch.rpm    

            echo "instalando de manera local ansible"
            sudo yum localinstall ansible-2.5.7-1.el7.ans.noarch.rpm -y
```
4. Aqui observamos el numero de cpu y la customización de discos 

- vb.cpus = 1 = El numero de CPU que llevara cada maquina virtual 
- vb.customize ["storagectl", :id, = El id que llevaria cada disco

```
    vb.cpus = 1
      vb.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata", "--controller", "IntelAHCI"]
```

5. Aqui veremos la customización de cada disco, en este caso la variable "p" es donde iniciaria este bucle y creación de disco

- vb.customize ['createhd', '--filename', "extra_data_#{i}_#{p}_#{d}.vdi", '--size', 5 * 1024,'--format', "VDI"]

```
  ######
        (0..DISK_NUMBER).each do |p|
          d=p
          unless File.exist? ("extra_data_#{i}_#{p}_#{d}.vdi")
            vb.customize ['createhd', '--filename', "extra_data_#{i}_#{p}_#{d}.vdi", '--size', 5 * 1024,'--format', "VDI"]
          end
          # unless File.exist? ("docker_data#{i}_#{p}_#{d}.vdi")
          #   vb.customize ['createhd', '--filename', "docker_data_#{i}_#{p}_#{d}.vdi", '--size', 6 * 1024]
          # end
              vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', "#{p}", '--device', 0, '--type',  'hdd', '--medium', "extra_data_#{i}_#{p}_#{d}.vdi"]
             # vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', "#{p}", '--device', 0, '--type',  'hdd', '--medium', "docker_data_#{i}_#{p}_#{d}.vdi"]
        end
    end
  end
end
end
```

- Luego hayamos entendido en concreto el Vagrantfile y sus componentes pasaremos a aprender de "Relacion de Confianza"


6. En nuestro Vagrantfile observamos que el paso "generando llave publica", esto lo que hace es generar de manera automatica y desasistida la creacion de la llave publica que es donde nosotros estableceremos la relacion de confianza con los nodos restantes
```
echo "generando llave publica"
            su - vagrant -c "ssh-keygen -q -t rsa -N '' -f /home/vagrant/.ssh/id_rsa"

            echo "validando si se creo llave public"
            cat /home/vagrant/.ssh/id_rsa.pub
```
NOTA: Este paso solo se ejecuta en la VM4 puesto que es nuestro Bastión y es donde queremos establecer la relación de confianza desde el Bastión con todos nuestro nodos

7. Seguimos con el paso "reiniciando servicio sshd", esto para que habilite la opción de autenticación con contraseña, y reiniciamos el servicio de ssh.service para que tome los cambios , este paso se ejecuta en todos los nodos.
```
echo "reiniciando servicio sshd"
            sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            systemctl restart sshd.service
          SHELL
```
8. Por último en nuestro bastion-ELK utilizaremos el modulo "authorized keys", esto para poder compartir nuestra llave publica con los demas nodos
```
- name: Set up multiple authorized keys
  authorized_key:
    user: vagrant
    state: present
    key: '{{ item }}'
  with_file:
    - keyvm4

```
Fuentes:

- https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide  / Relacion de Confianza
- https://www.vagrantup.com/docs/networking/forwarded_ports / Vagrant, forwardear puerto 
- https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html / Ansible, todo los modulos
- https://vagrant-intro.readthedocs.io/es/latest/aprovisionamiento.html / Vagrant, aprovisionamiento
