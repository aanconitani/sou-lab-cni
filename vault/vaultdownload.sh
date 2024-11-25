#!/usr/bin/env bash

#VAULT_RELEASE=$1
#VAULT_BINARY_FOLDER=$2
#VAULT_FOLDER_PREFIX=$3
#  ##  If someone passes in a third argument, put all files other than the binary under 
#  ##  a specific folder.
#  ##  If no one passes in a third argument, this has no effect. 
#
#  ##  Version determined by $1, e.g. 0.10.2
#curl -s -o "/tmp/vault_${1}_linux_arm64.zip" "https://releases.hashicorp.com/vault/${1}/vault_${1}_linux_arm64.zip"
#mkdir -p -v -m 0755 "${VAULT_BINARY_FOLDER}"
#echo "unzip -o /tmp/vault_${1}_linux_arm64.zip -d ${VAULT_BINARY_FOLDER}"
#unzip -o /tmp/vault_${1}_linux_arm64.zip -d "${VAULT_BINARY_FOLDER}"
#echo "Vault Release: ${1}"
#echo "Vault Download: https://releases.hashicorp.com/vault/${1}/vault_${1}_linux_arm64.zip"
#echo "Vault Path: ${2}"
#
#mkdir -p -v -m 0755 "${VAULT_FOLDER_PREFIX}/etc/ssl/vault/"
#mkdir -p -v -m 755 "${VAULT_FOLDER_PREFIX}/etc/vault.d"
#mkdir -p -v -m 755 "${VAULT_FOLDER_PREFIX}/etc/vault.d/plugin"
#chown -R vault:vault "${VAULT_FOLDER_PREFIX}/etc/vault.d" "${VAULT_FOLDER_PREFIX}/etc/ssl/vault"
#touch "${VAULT_FOLDER_PREFIX}/etc/vault.d/vault.hcl"
#chmod -R 0644 $VAULT_FOLDER_PREFIX/etc/vault.d/*
#chown vault:vault "${VAULT_BINARY_FOLDER}/vault"
#chmod 755 "${VAULT_BINARY_FOLDER}/vault"
#
#echo 'export VAULT_ADDR=http://localhost:8200  ##  Add Vault address to startup script'|sudo tee /etc/profile.d/vault.sh


#!/usr/bin/env bash

# Variables
VAULT_RELEASE=$1
VAULT_BINARY_FOLDER=$2
VAULT_FOLDER_PREFIX=${3:-""}  # Default to empty string if not provided.

if [[ -z "$VAULT_RELEASE" || -z "$VAULT_BINARY_FOLDER" ]]; then
  echo "Usage: $0 <vault_version> <binary_folder> [folder_prefix]"
  exit 1
fi

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

# Download Vault binary
echo "Downloading Vault $VAULT_RELEASE..."
curl -s -o "/tmp/vault_${VAULT_RELEASE}_linux_arm64.zip" "https://releases.hashicorp.com/vault/${VAULT_RELEASE}/vault_${VAULT_RELEASE}_linux_arm64.zip"
if [[ $? -ne 0 ]]; then
  echo "Failed to download Vault binary. Exiting."
  exit 1
fi

# Extract Vault binary
mkdir -p -v -m 0755 "${VAULT_BINARY_FOLDER}"
unzip -o "/tmp/vault_${VAULT_RELEASE}_linux_arm64.zip" -d "${VAULT_BINARY_FOLDER}"
if [[ $? -ne 0 ]]; then
  echo "Failed to unzip Vault binary. Exiting."
  exit 1
fi

# Ensure vault user and group exist
if ! id -u vault &>/dev/null; then
  echo "Creating vault user and group..."
  sudo groupadd vault
  sudo useradd -r -g vault -s /bin/false vault
fi

# Set ownership and permissions for the Vault binary
chown vault:vault "${VAULT_BINARY_FOLDER}/vault"
chmod 755 "${VAULT_BINARY_FOLDER}/vault"

# Create directories for Vault configuration
mkdir -p -v -m 0755 "${VAULT_FOLDER_PREFIX}/etc/ssl/vault/"
mkdir -p -v -m 0755 "${VAULT_FOLDER_PREFIX}/etc/vault.d"
mkdir -p -v -m 0755 "${VAULT_FOLDER_PREFIX}/etc/vault.d/plugin"

# Set ownership and permissions for Vault configuration
chown -R vault:vault "${VAULT_FOLDER_PREFIX}/etc/vault.d" "${VAULT_FOLDER_PREFIX}/etc/ssl/vault"
touch "${VAULT_FOLDER_PREFIX}/etc/vault.d/vault.hcl"
chmod -R 0644 "${VAULT_FOLDER_PREFIX}/etc/vault.d"/*

# Add Vault address to the environment
echo 'export VAULT_ADDR=http://localhost:8200' | sudo tee /etc/profile.d/vault.sh

# Output details
echo "Vault Release: ${VAULT_RELEASE}"
echo "Vault Download: https://releases.hashicorp.com/vault/${VAULT_RELEASE}/vault_${VAULT_RELEASE}_linux_arm64.zip"
echo "Vault Binary Path: ${VAULT_BINARY_FOLDER}/vault"
echo "Configuration Path: ${VAULT_FOLDER_PREFIX}/etc/vault.d"
