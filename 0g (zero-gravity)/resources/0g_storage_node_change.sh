#!/bin/bash

# Function to query the latest block number from a JSON-RPC endpoint
query_block_number() {
    local endpoint=$1
    local block_number=$(curl -s -X POST "$endpoint" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    echo "$block_number"
}

# Function to prompt user to choose JSON-RPC endpoint
choose_json_rpc_endpoint() {
    echo "Choose your JSON-RPC endpoint:"
    echo "1. Enter your own JSON-RPC endpoint"
    echo "2. Use a public JSON-RPC endpoint"
    read -p "Enter your choice (1/2): " JSON_RPC_CHOICE

    if [ "$JSON_RPC_CHOICE" == "1" ]; then
        read -p "Enter your JSON-RPC endpoint (leave empty to skip): " BLOCKCHAIN_RPC_ENDPOINT
        if [ -n "$BLOCKCHAIN_RPC_ENDPOINT" ]; then
            BLOCK_NUMBER=$(query_block_number "$BLOCKCHAIN_RPC_ENDPOINT")
            echo "Latest block number for $BLOCKCHAIN_RPC_ENDPOINT: $BLOCK_NUMBER"
            read -p "Do you want to continue with this RPC endpoint? (yes/no): " CONTINUE_CHOICE
            if [ "$CONTINUE_CHOICE" != "yes" ]; then
                choose_json_rpc_endpoint
            fi
        else
            BLOCKCHAIN_RPC_ENDPOINT=""
        fi
    elif [ "$JSON_RPC_CHOICE" == "2" ]; then
        echo "Available public JSON-RPC endpoints:"
        echo "1. https://lightnode-json-rpc-0g.grandvalleys.com [$(query_block_number https://lightnode-json-rpc-0g.grandvalleys.com)]"
        echo "2. https://evmrpc-testnet.0g.ai [$(query_block_number https://evmrpc-testnet.0g.ai)]"
        echo "3. https://rpc.ankr.com/0g_newton [$(query_block_number https://rpc.ankr.com/0g_newton)]"
        echo "4. https://0g-json-rpc-public.originstake.com [$(query_block_number https://0g-json-rpc-public.originstake.com)]"
        echo "5. https://og-testnet-jsonrpc.itrocket.net:443 [$(query_block_number https://og-testnet-jsonrpc.itrocket.net:443)]"
        echo "6. https://0g-evmrpc-zstake.xyz [$(query_block_number https://0g-evmrpc-zstake.xyz)]"
        echo "7. https://zerog-testnet-json-rpc.contributiondao.com [$(query_block_number https://zerog-testnet-json-rpc.contributiondao.com)]"
        echo "8. https://16600.rpc.thirdweb.com [$(query_block_number https://16600.rpc.thirdweb.com)]"
        read -p "Enter the number of your chosen public JSON-RPC endpoint: " PUBLIC_RPC_CHOICE

        if [ -n "$PUBLIC_RPC_CHOICE" ]; then
            case $PUBLIC_RPC_CHOICE in
                1) BLOCKCHAIN_RPC_ENDPOINT="https://lightnode-json-rpc-0g.grandvalleys.com";;
                2) BLOCKCHAIN_RPC_ENDPOINT="https://evmrpc-testnet.0g.ai";;
                3) BLOCKCHAIN_RPC_ENDPOINT="https://rpc.ankr.com/0g_newton";;
                4) BLOCKCHAIN_RPC_ENDPOINT="https://0g-json-rpc-public.originstake.com";;
                5) BLOCKCHAIN_RPC_ENDPOINT="https://og-testnet-jsonrpc.itrocket.net:443";;
                6) BLOCKCHAIN_RPC_ENDPOINT="https://0g-evmrpc-zstake.xyz";;
                7) BLOCKCHAIN_RPC_ENDPOINT="https://zerog-testnet-json-rpc.contributiondao.com";;
                8) BLOCKCHAIN_RPC_ENDPOINT="https://16600.rpc.thirdweb.com";;
                *) echo "Invalid choice. Exiting."; exit 1;;
            esac
        else
            BLOCKCHAIN_RPC_ENDPOINT=""
        fi
    else
        echo "Invalid choice. Exiting."; exit 1
    fi
}

# Function to prompt user to change miner key
change_miner_key() {
    read -p "Enter your private key (leave empty to skip): " PRIVATE_KEY
}

# Main function to handle user choices
main() {
    echo "Choose what you want to change:"
    echo "1. Change RPC endpoint"
    echo "2. Change miner key"
    read -p "Enter your choice (1/2): " USER_CHOICE

    if [ "$USER_CHOICE" == "1" ]; then
        choose_json_rpc_endpoint
        read -p "Do you want to change the miner key as well? (yes/no): " CHANGE_MINER_KEY
        if [ "$CHANGE_MINER_KEY" == "yes" ]; then
            change_miner_key
        fi
    elif [ "$USER_CHOICE" == "2" ]; then
        change_miner_key
        read -p "Do you want to change the RPC endpoint as well? (yes/no): " CHANGE_RPC
        if [ "$CHANGE_RPC" == "yes" ]; then
            choose_json_rpc_endpoint
        fi
    else
        echo "Invalid choice. Exiting."; exit 1
    fi

    # Stop the storage node
    sudo systemctl stop zgs

    # Update config file
    CONFIG_FILE="$HOME/0g-storage-node/run/config-testnet.toml"

    # Read existing values from the config file
    EXISTING_MINER_KEY=$(grep -oP 'miner_key\s*=\s*"\K[^"]+' "$CONFIG_FILE")
    EXISTING_RPC_ENDPOINT=$(grep -oP 'blockchain_rpc_endpoint\s*=\s*"\K[^"]+' "$CONFIG_FILE")

    # Update only if new values are provided
    if [ -n "$PRIVATE_KEY" ]; then
        sed -i "s|^\s*#\?\s*miner_key\s*=.*|miner_key = \"$PRIVATE_KEY\"|" "$CONFIG_FILE"
    else
        PRIVATE_KEY=$EXISTING_MINER_KEY
    fi

    if [ -n "$BLOCKCHAIN_RPC_ENDPOINT" ]; then
        sed -i "s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = \"$BLOCKCHAIN_RPC_ENDPOINT\"|" "$CONFIG_FILE"
    else
        BLOCKCHAIN_RPC_ENDPOINT=$EXISTING_RPC_ENDPOINT
    fi

    sed -i "
    s|^\s*#\?\s*listen_address\s*=.*|listen_address = \"0.0.0.0:5678\"|
    s|^\s*#\?\s*listen_address_admin\s*=.*|listen_address_admin = \"0.0.0.0:5679\"|
    s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
    " "$CONFIG_FILE"

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
}

# Execute the main function
main
