#!/bin/bash

# Function to query the latest block number from a JSON-RPC endpoint
query_block_number() {
    local endpoint=$1
    local block_number=$(curl -s -X POST $endpoint -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    echo $block_number
}

# Function to prompt user to choose JSON-RPC endpoint
choose_json_rpc_endpoint() {
    echo "Choose your JSON-RPC endpoint:"
    echo "1. Enter your own JSON-RPC endpoint"
    echo "2. Use a public JSON-RPC endpoint"
    read -p "Enter your choice (1/2): " JSON_RPC_CHOICE

    if [ "$JSON_RPC_CHOICE" == "1" ]; then
        read -p "Enter your JSON-RPC endpoint: " BLOCKCHAIN_RPC_ENDPOINT
        BLOCK_NUMBER=$(query_block_number $BLOCKCHAIN_RPC_ENDPOINT)
        echo "Latest block number for $BLOCKCHAIN_RPC_ENDPOINT: $BLOCK_NUMBER"
        read -p "Do you want to continue with this RPC endpoint? (yes/no): " CONTINUE_CHOICE
        if [ "$CONTINUE_CHOICE" != "yes" ]; then
            choose_json_rpc_endpoint
        fi
    elif [ "$JSON_RPC_CHOICE" == "2" ]; then
        echo "Available public JSON-RPC endpoints:"
        echo "1. https://lightnode-json-rpc-0g.grandvalleys.com [$(query_block_number https://lightnode-json-rpc-0g.grandvalleys.com)]"
        echo "2. https://evmrpc-testnet.0g.ai [$(query_block_number https://evmrpc-testnet.0g.ai)]"
        echo "3. https://rpc.ankr.com/0g_newton [$(query_block_number https://rpc.ankr.com/0g_newton)]"
        echo "4. https://16600.rpc.thirdweb.com [$(query_block_number https://16600.rpc.thirdweb.com)]"
        echo "5. https://0g-json-rpc-public.originstake.com [$(query_block_number https://0g-json-rpc-public.originstake.com)]"
        echo "6. https://0g-rpc-evm01.validatorvn.com [$(query_block_number https://0g-rpc-evm01.validatorvn.com)]"
        echo "7. https://og-testnet-jsonrpc.itrocket.net:443 [$(query_block_number https://og-testnet-jsonrpc.itrocket.net:443)]"
        echo "8. https://0g-evmrpc-zstake.xyz [$(query_block_number https://0g-evmrpc-zstake.xyz)]"
        echo "9. https://zerog-testnet-json-rpc.contributiondao.com [$(query_block_number https://zerog-testnet-json-rpc.contributiondao.com)]"
        read -p "Enter the number of your chosen public JSON-RPC endpoint: " PUBLIC_RPC_CHOICE

        case $PUBLIC_RPC_CHOICE in
            1) BLOCKCHAIN_RPC_ENDPOINT="https://lightnode-json-rpc-0g.grandvalleys.com";;
            2) BLOCKCHAIN_RPC_ENDPOINT="https://evmrpc-testnet.0g.ai";;
            3) BLOCKCHAIN_RPC_ENDPOINT="https://rpc.ankr.com/0g_newton";;
            4) BLOCKCHAIN_RPC_ENDPOINT="https://16600.rpc.thirdweb.com";;
            5) BLOCKCHAIN_RPC_ENDPOINT="https://0g-json-rpc-public.originstake.com";;
            6) BLOCKCHAIN_RPC_ENDPOINT="https://0g-rpc-evm01.validatorvn.com";;
            7) BLOCKCHAIN_RPC_ENDPOINT="https://og-testnet-jsonrpc.itrocket.net:443";;
            8) BLOCKCHAIN_RPC_ENDPOINT="https://0g-evmrpc-zstake.xyz";;
            9) BLOCKCHAIN_RPC_ENDPOINT="https://zerog-testnet-json-rpc.contributiondao.com";;
            *) echo "Invalid choice. Exiting."; exit 1;;
        esac
    else
        echo "Invalid choice. Exiting."; exit 1
    fi
}

# Prompt user for storage node URLs
read -p "Enter storage node URLs (e.g., http://STORAGE_NODE_IP:5678,http://STORAGE_NODE_IP:5679): " ZGS_NODE
echo "Current storage node URLs: $ZGS_NODE"

# Prompt user to choose JSON-RPC endpoint
choose_json_rpc_endpoint

echo "Current JSON-RPC endpoint: $BLOCKCHAIN_RPC_ENDPOINT"

# Prompt user for contract type
read -p "Choose contract type (turbo/standard): " CONTRACT_TYPE

if [ "$CONTRACT_TYPE" == "turbo" ]; then
    LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"
elif [ "$CONTRACT_TYPE" == "standard" ]; then
    LOG_CONTRACT_ADDRESS="0x0460aA47b41a66694c0a73f667a1b795A5ED3556"
else
    echo "Invalid contract type. Please choose either 'turbo' or 'standard'."
    exit 1
fi

## Update the storage kv (in case you're still in the previous version)

### 1. Stop storage kv
sudo systemctl stop zgskv

### 2. Update node
cd $HOME/0g-storage-kv
git stash
git fetch --all --tags
git checkout e7c737901d8953d6b73857dc8d7fb1740a416c5d
git submodule update --init

### 3. Build the latest binary
cargo build --release

### 4. Set vars
echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
echo "export ZGS_NODE=\"$ZGS_NODE\"" >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile

source ~/.bash_profile

echo 'export LOG_CONTRACT_ADDRESS="'"$LOG_CONTRACT_ADDRESS"'"' >> ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE KV VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"lets buidl together\" - Grand Valley\033[0m"

### 5. Update storage kv configuration
rm -rf $HOME/0g-storage-kv/run/config.toml && cp $HOME/0g-storage-kv/run/config_example.toml $HOME/0g-storage-kv/run/config.toml

sed -i '
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*rpc_listen_address\s*=.*|rpc_listen_address = "0.0.0.0:6789"|
s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
s|^\s*#\?\s*kv_db_dir\s*=.*|kv_db_dir = "kv.DB"|
s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*zgs_node_urls\s*=.*|zgs_node_urls = "'"$ZGS_NODE"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-kv/run/config.toml

### 6. Restart the node
sudo systemctl daemon-reload && \
sudo systemctl restart zgskv && \
sudo systemctl status zgskv

### 7. Show the logs
echo "To check the logs, use the command: sudo journalctl -u zgskv -fn 100 -o cat"

# Confirmation message for installation completion
if systemctl is-active --quiet zgskv; then
    echo "Storage KV installation and services started successfully!"
else
    echo "Storage KV installation failed. Please check the logs for more information."
fi

echo "Let's Buidl 0G Together"