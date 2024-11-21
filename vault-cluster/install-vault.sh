#Install yum-config-manager to manage your repositories.

yum install -y yum-utils

#Use yum-config-manager to add the official HashiCorp Linux repository.

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

#Install Vault.

yum -y install vault