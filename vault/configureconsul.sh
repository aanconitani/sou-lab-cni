# Extract the first matching 192.x.x.x IP address
IP_ADDRESS=$(hostname -I | grep -Eo '192\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)

# Verify the IP address is not empty
if [ -z "$IP_ADDRESS" ]; then
  echo "Error: Could not determine advertise_addr. Exiting."
  exit 1
fi

#bash -c "cat >/etc/consul.d/consul.json" << EOF
cat <<EOF >/etc/consul.d/consul.json
{
  "server": true,
  "bootstrap_expect": 3,
  "raft_protocol": 3,
  "datacenter": "superduper",
  "raft_protocol": 3,
  "retry_join": ["192.168.13.35","192.168.13.36","192.168.13.37"],
  "advertise_addr": "$IP_ADDRESS",  
  "leave_on_terminate": true,
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "acl_datacenter": "superduper",
  "acl_default_policy": "deny",
  "acl_down_policy": "allow",
  "acl_agent_master_token": "testtoken",
  "acl_master_token":"a4c878e5-a0eb-48ef-b6b4-00e18a146bf2"
}
EOF

  ##  Tell the OS to run Consul Snapshot
  ##  once per hour.
line="*/60 * * * * /usr/local/bin/consul snapshot save \"/opt/consul/snapshots/consul_snapshot_$(date '+%Y%m%dT%H%M%S').snap\""
(crontab -u $USER -l; echo "$line" ) | crontab -u $USER -
