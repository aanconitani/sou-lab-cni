release=1.20.1
##release="$(curl -s https://releases.hashicorp.com/consul/index.json|jq -r '.versions[].version'|tail -n 1)"
download="https://releases.hashicorp.com/consul/${release}/consul_${release}_linux_arm64.zip"
echo "Consul Release: ${release}"
echo "Consul Download: ${download}"
curl -s -o consul_${release}_linux_arm64.zip ${download}
unzip consul_${release}_linux_arm64.zip
#sudo yum install -y yum-utils
#sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
#sudo yum -y install consul
sudo mv consul /usr/local/bin/
chmod 755 /usr/local/bin/consul
chown consul:consul /usr/local/bin/consul
mkdir -p -v -m 755 /etc/consul.d
touch /etc/consul.d/consul.json
mkdir -p -v -m 755 /opt/consul/data
chown -R consul:consul /etc/consul.d /opt/consul
chmod -R 0644 /etc/consul.d/*