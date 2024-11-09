# sou-lab-cni
Studio di Bash, Vagrant, Ansible, Prometheus, Grafana, Haproxy, Podman

###INSTALLAZIONE INIZIALE###

# Installo rosetta
/usr/sbin/softwareupdate - install-rosetta - agree-to-license

# Installo vagrant_2.4.1_darwin_arm64.dmg

# Installo Vmware Fusion VMware-Fusion-13.6.1-24319021_universal.dmg

# Installo vagrant-vmware-utility_1.0.23_darwin_arm64.dmg

# Installo il plugin di Vmware per Vagrant 
vagrant plugin install vagrant-vmware-desktop

###INIZIO PROGETTO###

#Creazione di un progetto Vagrant multinodo (2 nodi: soufe1 e soube2) con comunicazione su interfacce
#network locali (scegliere una subnet a piacere in 192.168.0.0/16) (in caso di Mac con chip Apple, passare
#oltre)
#Scegliere la distribuzione tra Centos, Almalinux, RockyLinux e Oracle Linux (in caso di Mac con chip Apple,
#passare oltre)

cd sou-lab-cni
vi Vagrantfile

#Configurazione globale
Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-stream-9-arm64"
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.memory = 2048
    vmware.cpus = 1
    vmware.gui = true
    vmware.allowlist_verified = true
  end

#Configurazione soufe1
  config.vm.define "soufe1" do |soufe1|
    soufe1.vm.network "private_network", ip: "192.168.50.11"
    soufe1.vm.hostname = "soufe1"
  end

#Configurazione soube2
  config.vm.define "soube2" do |soube2|
    soube2.vm.network "private_network", ip: "192.168.50.12"
    soube2.vm.hostname = "soube2"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./ansible/deploy.yml"
    ansible.become = true
    ansible.compatibility_mode = "2.0"
  end
end

#Creazione di un ruolo Ansible denominato sou_podman (capire come si crea un ruolo Ansible). Nei punti
#successivi sono espresse le azioni che deve compiere l'automatismo (in caso di Mac con chi Apple, Ansible
#viene eseguito sulla propria workstation)
#Installare podman su soufe1 e soube2 (in caso di Mac con chi Apple, passare oltre) 


# Creo il ruolo Ansible

mkdir -p ansible/roles/sou_podman/tasks/
cd ansible/roles/sou_podman/tasks/
vi install_podman.yml

- name: Update packages 
  dnf:
    name: "*"
    state: latest
  become: true

- name: Install Podman
  dnf:
    name: podman
    state: present
  become: true

- name: Enable and start Podman
  systemd:
    name: podman.socket
    enabled: true
    state: started
  become: true

# Creo il playbook che chiamerà i vari roles

cd ../../../
vi deploy.yml

- name: Install Podman on soufe1 and soube2
  hosts: all
  become: true
  roles:
    - sou_podman
