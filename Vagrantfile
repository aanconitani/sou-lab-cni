#Configurazione globale
Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-stream-9-arm64"
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.memory = 2048
    vmware.cpus = 1
#    vmware.gui = true
    vmware.allowlist_verified = true
  end

#Configurazione soufe1
  config.vm.define "soufe1" do |soufe1|
    soufe1.vm.network "private_network", ip: "192.168.50.11"
    soufe1.vm.hostname = "soufe1.local"
  end

#Configurazione soube2
  config.vm.define "soube2" do |soube2|
    soube2.vm.network "private_network", ip: "192.168.50.12"
    soube2.vm.hostname = "soube2.local"
  end

#Configurazione soube3
  config.vm.define "soube3" do |soube3|
    soube3.vm.network "private_network", ip: "192.168.50.13"
    #soube3.vm.network "forwarded_port", guest: 8200, host: 8200
    #soube3.vm.network "forwarded_port", guest: 8201, host: 8201
    soube3.vm.hostname = "soube3.local" 
   #Installo Vault
    soube3.vm.provision "shell", path: "vault-cluster/install-vault.sh"
   #Setup iniziale 
    soube3.vm.provision "shell", path: "vault-cluster/raft-storage/local/cluster.sh", :args => "create network"
    soube3.vm.provision "shell", path: "vault-cluster/raft-storage/local/cluster.sh", :args => "create config" 
    soube3.vm.provision "shell", path: "vault-cluster/raft-storage/local/cluster.sh", :args => "setup vault_1" 
    soube3.vm.provision "shell", path: "vault-cluster/raft-storage/local/cluster.sh", :args => "setup vault_2" 
    soube3.vm.provision "shell", path: "vault-cluster/raft-storage/local/cluster.sh", :args => "setup vault_3" 
    soube3.vm.provision "shell", path: "vault-cluster/raft-storage/local/cluster.sh", :args => "setup vault_4" 
   #Creo il cluster HA
    soube3.vm.provision "shell", path: "vault-cluster/join-nodes-to-cluster.sh"
   #Update dei listner
    #soube3.vm.provision "shell", path: "vault-cluster/update-listner.sh"
   #Espongo il servizio
    #soube3.vm.network "forwarded_port", guest: 8200, host: 8202
   end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./ansible/deploy.yml"
    ansible.become = true
    ansible.compatibility_mode = "2.0"
  end
end
