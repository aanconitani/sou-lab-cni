#release=1.20.1
##release="$(curl -s https://releases.hashicorp.com/consul/index.json|jq -r '.versions[].version'|grep -v 'ent\|rc\|beta'|tail -n 1)"
##release="$(curl -s https://releases.hashicorp.com/consul/index.json|jq -r '.versions[].version'|tail -n 1)"
#download="https://releases.hashicorp.com/consul/${release}/consul_${release}_linux_arm64.zip"
#echo "Consul Release: ${release}"
#echo "Consul Download: ${download}"
#curl -s -o /tmp/consul_${release}_linux_arm64.zip ${download}
#unzip -o /tmp/consul_${release}_linux_arm64.zip -d /usr/local/bin/
#chmod 755 /usr/local/bin/consul
#chown consul:consul /usr/local/bin/consul
#mkdir -p -v -m 755 /etc/consul.d
#touch /etc/consul.d/consul.json
#mkdir -p -v -m 755 /opt/consul/data
#chown -R consul:consul /etc/consul.d /opt/consul
#chmod -R 0644 /etc/consul.d/*

#!/usr/bin/env bash

# Set the Consul version to install
release=1.20.1
download="https://releases.hashicorp.com/consul/${release}/consul_${release}_linux_arm64.zip"

echo "Consul Release: ${release}"
echo "Consul Download: ${download}"

# Install unzip if not present
if ! command -v unzip &>/dev/null; then
    echo "Installing unzip..."
    sudo apt-get update -qq || sudo yum check-update -q || echo "Could not update package manager."
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y unzip
    elif command -v yum &>/dev/null; then
        sudo yum install -y unzip
    else
        echo "Could not detect package manager. Exiting."
        exit 1
    fi
fi

# Download and install Consul
curl -s -o /tmp/consul_${release}_linux_arm64.zip ${download}
if [ $? -ne 0 ]; then
    echo "Error downloading Consul from ${download}. Exiting."
    exit 1
fi

unzip -o /tmp/consul_${release}_linux_arm64.zip -d /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error extracting Consul binary. Exiting."
    exit 1
fi

chmod 755 /usr/local/bin/consul

# Ensure the consul user and group exist
if ! id -u consul &>/dev/null; then
    echo "Creating consul user and group..."
    sudo groupadd consul
    sudo useradd -r -g consul -s /bin/false consul
fi

# Set permissions for the Consul binary
chown consul:consul /usr/local/bin/consul

# Create directories for Consul
mkdir -p -v -m 0755 /etc/consul.d
touch /etc/consul.d/consul.json
mkdir -p -v -m 0755 /opt/consul/data

# Set ownership for Consul directories
chown -R consul:consul /etc/consul.d /opt/consul
chmod -R 0644 /etc/consul.d/*

echo "Consul installation and setup completed."

