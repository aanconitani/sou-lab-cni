#Set the VAULT_ADDR to vault_3 API address.
export VAULT_ADDR="http://127.0.0.3:8200"

#Join vault_3 to the vault_2 cluster.
vault operator raft join http://127.0.0.2:8200

#Set the VAULT_ADDR to vault_4 API address.
export VAULT_ADDR="http://127.0.0.4:8200"

#Join vault_4 to the vault_2 cluster.
vault operator raft join http://127.0.0.2:8200


#Join vault_3 to the vault_2 cluster.
#xport VAULT_TOKEN=$(cat root_token-vault_2)
#
#Examine the current raft peer set.
#ault operator raft list-peers
#
#verify that you can read the secret at kv/apikey.
#ault kv get kv/apikey

#Join vault_4 to cluster (verify rejoin)
#export VAULT_ADDR="http://127.0.0.4:8200"
#export VAULT_TOKEN=$(cat root_token-vault_2)
#vault kv patch kv/apikey expiration="365 days"
#vault kv get kv/apikey