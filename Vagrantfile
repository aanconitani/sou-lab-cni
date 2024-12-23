# -*- mode: ruby -*-
# vi: set ft=ruby :

#Configurazione globale
Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-stream-9-arm64"
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.memory = 1024
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

  #Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
  ##  This example uses three boxes. instance5, instance6, and instance7. 
    (5..7).each do |i|
        config.vm.define "instance#{i}" do |server|
            server.vm.box = "bento/centos-stream-9-arm64" 
            server.vm.hostname = "instance#{i}"
            server.vm.network :private_network, ip: "192.168.13.3#{i}"
            server.vm.provision "shell", path: "vault/account.sh", args: "vault"
            server.vm.provision "shell", path: "vault/account.sh", args: "consul"
            server.vm.provision "shell", path: "vault/prereqs.sh"
            server.vm.provision "shell", path: "vault/consulsystemd.sh"
            server.vm.provision "shell", path: "vault/vaultsystemd.sh"
            server.vm.provision "shell", path: "vault/consuldownload.sh"
            server.vm.provision "shell", path: "vault/configureconsul.sh"
            server.vm.provision "shell", inline: "sudo systemctl enable consul.service"
            server.vm.provision "shell", inline: "sudo systemctl start consul"
            server.vm.provision "shell", path: "vault/vaultdownload.sh", args: ["1.0.0-rc1", "/usr/local/bin"]
            
              ##  API Provisioning
            if "#{i}" == "7"
                #server.vm.provision "shell", inline: "consul member -http-addr=localhost:8500 ; sleep 10"
                server.vm.provision "shell", inline: "echo 'Provisioning Consul ACLs via this host: '; hostname"
                server.vm.provision "shell", path: "vault/provision_consul/scripts/acl/consul_acl.sh"
                server.vm.provision "shell", path: "vault/provision_consul/scripts/acl/consul_acl_vault.sh"
                else
                server.vm.provision "shell", inline: "echo 'Not provisioning Consul ACLs via this host: '; hostname"
            end
        end
    end


    config.vm.define "instance7" do |consul_acl|
#        consul_acl.vm.provision "shell", preserve_order: true, inline: "echo 'Provisioning Consul ACLs via this host: '; hostname"
#        consul_acl.vm.provision "shell", preserve_order: true, path: "provision_consul/scripts/acl/consul_acl.sh"
#        consul_acl.vm.provision "shell", preserve_order: true, path: "provision_consul/scripts/acl/consul_acl_vault.sh"
    end

    (5..7).each do |i|
        config.vm.define "instance#{i}" do |vault|
            vault.vm.provision "shell", preserve_order: true, path: "vault/configurevault.sh"
            vault.vm.provision "shell", preserve_order: true, inline: "sudo systemctl enable vault.service"
            vault.vm.provision "shell", preserve_order: true, inline: "sudo systemctl start vault"
        end
    end

  ##  Consul ACL Configuration
  ##  You'll notice that Consul ACL bootstrapping only succeeds on the first VM.
  ##  Choice of instance5 is not arbitrary. It could be done from within any instance
  ##  running one of the members of the Consul cluster, but instance5
  ##  gets provisioned first.

  ##  Vault's start may only happen after Consul ACL Configuration, because
  ##  it requires a Consul ACL to exist on a running Consul Cluster.

  ##  DB Secret backend
    config.vm.define "db" do |db|
        db.vm.box = "bento/centos-stream-9-arm64"
        db.vm.network :private_network, ip: "192.168.13.187"
        db.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "vault/playbooks/prereqs.yaml"
        end
        db.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "vault//playbooks/mariadb.yaml"
            ansible.extra_vars = {'enable_external_conn': true, 'add_root_priv': !ARGV.include?('provision')}
        end
    end
end
