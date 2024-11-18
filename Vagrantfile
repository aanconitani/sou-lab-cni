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

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./ansible/deploy.yml"
    ansible.become = true
    ansible.compatibility_mode = "2.0"
  end
end
