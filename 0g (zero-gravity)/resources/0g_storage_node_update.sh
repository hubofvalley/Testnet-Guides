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

# Prompt user for JSON-RPC endpoint
choose_json_rpc_endpoint

# Prompt user for private key
read -p "Enter your private key: " PRIVATE_KEY
echo "private key: $PRIVATE_KEY"

# Prompt user for contract type
read -p "Choose contract type (turbo/standard): " CONTRACT_TYPE

# Stop the storage node
sudo systemctl stop zgs

# Update the node
cd $HOME/0g-storage-node
git stash
git fetch --all --tags
git checkout 74074dfa2f40c1dcdd8aecbb25257d5a77930505
git submodule update --init

# Build the latest binary
cargo build --release

# Set environment variables
echo "export ENR_ADDRESS=${ENR_ADDRESS}" >> ~/.bash_profile
echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE NODE VARIABLES\033[0m\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"lets buidl together\" - Grand Valley\033[0m"

# Update node configuration based on contract type
if [ "$CONTRACT_TYPE" == "turbo" ]; then
    rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-turbo.toml $HOME/0g-storage-node/run/config-testnet.toml
elif [ "$CONTRACT_TYPE" == "standard" ]; then
    rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-standard.toml $HOME/0g-storage-node/run/config-testnet.toml
else
    echo "Invalid contract type. Please choose either 'turbo' or 'standard'."
    exit 1
fi

sed -i "
s|^\s*#\s*miner_key\s*=.*|miner_key = \"$PRIVATE_KEY\"|
s|^\s*#\s*listen_address\s*=.*|listen_address = \"0.0.0.0:5678\"|
s|^\s*#\s*listen_address_admin\s*=.*|listen_address_admin = \"0.0.0.0:5679\"|
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = $ZGS_LOG_SYNC_BLOCK|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = \"$BLOCKCHAIN_RPC_ENDPOINT\"|
" $HOME/0g-storage-node/run/config-testnet.toml

# Restart the node
sudo systemctl daemon-reload && \
sudo systemctl restart zgs && \
sudo systemctl status zgs

# Show logs
echo "Full logs command: tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)"

# Confirmation message for update completion
if systemctl is-active --quiet zgs; then
    echo "Storage Node update and services restarted successfully!"
else
    echo "Storage Node update failed. Please check the logs for more information."
fi

echo "Let's Buidl 0G Together"
