#!/bin/bash

# Define new boot nodes
BOOT_NODES=(
  "/ip4/47.251.79.83/udp/1234/p2p/16Uiu2HAkvJYQABP1MdvfWfUZUzGLx1sBSDZ2AT92EFKcMCCPVawV"
  "/ip4/47.238.87.44/udp/1234/p2p/16Uiu2HAmFGsLoajQdEds6tJqsLX7Dg8bYd2HWR4SbpJUut4QXqCj"
  "/ip4/47.251.78.104/udp/1234/p2p/16Uiu2HAmSe9UWdHrqkn2mKh99b9DwYZZcea6krfidtU3e5tiHiwN"
  "/ip4/47.76.30.235/udp/1234/p2p/16Uiu2HAm5tCqwGtXJemZqBhJ9JoQxdDgkWYavfCziaqaAYkGDSfU"
  "/ip4/47.251.88.201/udp/1234/p2p/16Uiu2HAmFGrDV8wKToa1dd8uh6bz8bSY28n33iRP3pvfeBU6ysCw"
  "/ip4/47.76.49.188/udp/1234/p2p/16Uiu2HAmBb7PQzvfZjHBENcF7E7mZaiHSrpBoH7mKTyNijYdqMM6"
)

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
        echo "4. https://0g-json-rpc-public.originstake.com [$(query_block_number https://0g-json-rpc-public.originstake.com)]"
        echo "5. https://og-testnet-jsonrpc.itrocket.net:443 [$(query_block_number https://og-testnet-jsonrpc.itrocket.net:443)]"
        echo "6. https://0g-evmrpc-zstake.xyz [$(query_block_number https://0g-evmrpc-zstake.xyz)]"
        echo "7. https://zerog-testnet-json-rpc.contributiondao.com [$(query_block_number https://zerog-testnet-json-rpc.contributiondao.com)]"
        read -p "Enter the number of your chosen public JSON-RPC endpoint: " PUBLIC_RPC_CHOICE

        case $PUBLIC_RPC_CHOICE in
            1) BLOCKCHAIN_RPC_ENDPOINT="https://lightnode-json-rpc-0g.grandvalleys.com";;
            2) BLOCKCHAIN_RPC_ENDPOINT="https://evmrpc-testnet.0g.ai";;
            3) BLOCKCHAIN_RPC_ENDPOINT="https://rpc.ankr.com/0g_newton";;
            4) BLOCKCHAIN_RPC_ENDPOINT="https://0g-json-rpc-public.originstake.com";;
            5) BLOCKCHAIN_RPC_ENDPOINT="https://og-testnet-jsonrpc.itrocket.net:443";;
            6) BLOCKCHAIN_RPC_ENDPOINT="https://0g-evmrpc-zstake.xyz";;
            7) BLOCKCHAIN_RPC_ENDPOINT="https://zerog-testnet-json-rpc.contributiondao.com";;
            *) echo "Invalid choice. Exiting."; exit 1;;
        esac
    else
        echo "Invalid choice. Exiting."; exit 1
    fi
}

echo -e "${YELLOW}⚠️  This script will DELETE your existing 0G Storage Node (${GREEN}zgs.service${YELLOW}) and install a fresh one.${RESET}"
echo -e "${RED}Proceed ONLY if you are aware of the consequences.${RESET}"
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Delete previous installation
echo -e "${RED}Deleting previous installation of 0G Storage Node...${RESET}"
sudo systemctl stop zgs.service 2>/dev/null
sudo systemctl disable zgs.service 2>/dev/null
sudo rm -f /etc/systemd/system/zgs.service
sudo rm -rf $HOME/0g-storage-node
echo -e "${GREEN}Previous storage node deleted successfully.${RESET}"

# Prompt user for private key
read -p "Enter your private key: " PRIVATE_KEY
echo "private key: $PRIVATE_KEY"

# Set contract type to turbo by default
CONTRACT_TYPE="turbo"

# Prompt user to choose JSON-RPC endpoint
choose_json_rpc_endpoint

echo "Current JSON-RPC endpoint: $BLOCKCHAIN_RPC_ENDPOINT"

# 1. Install dependencies for building from source
sudo apt-get update -y
sudo apt-get install clang cmake build-essential -y
sudo apt install git -y
sudo apt install libssl-dev -y
sudo apt install pkg-config -y
sudo apt-get install protobuf-compiler -y
sudo apt-get install clang -y
sudo apt-get install llvm llvm-dev -y

# 2. Install go
cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version

# 3. Install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 4. Set vars
echo 'export ZGS_LOG_SYNC_BLOCK="0"' >> ~/.bash_profile
echo "export ZGS_NODE_VERSION="v1.1.0"" >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
echo 'export LOG_CONTRACT_ADDRESS="'"0xbD75117F80b4E22698D0Cd7612d92BDb8eaff628"'"' >> ~/.bash_profile
source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE NODE VARIABLES\033[0m\nZGS_NODE_VERSION: $ZGS_NODE_VERSION\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"Let's Buidl 0G Together\" - Grand Valley\033[0m"

# Check JSON-RPC sync
curl -s -X POST $BLOCKCHAIN_RPC_ENDPOINT -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n"

# 5. Download binary
cd $HOME
git clone -b v1.1.0 https://github.com/0glabs/0g-storage-node.git
cd $HOME/0g-storage-node
git stash
git fetch --all --tags
git submodule update --init

# 6. Build the binary
cargo build --release


# 7. Check the storage node version
$HOME/0g-storage-node/target/release/zgs_node --version

# 8. Update node configuration based on contract type
if [ "$CONTRACT_TYPE" == "turbo" ]; then
    rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-turbo.toml $HOME/0g-storage-node/run/config-testnet.toml
#elif [ "$CONTRACT_TYPE" == "standard" ]; then
#    rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-standard.toml $HOME/0g-storage-node/run/config-testnet.toml
#else
#    echo "Invalid contract type. Please choose either 'turbo' or 'standard'."
#    exit 1
fi

sed -i "
s|^\s*#\?\s*network_boot_nodes\s*=.*|network_boot_nodes = [\"${BOOT_NODES[0]}\", \"${BOOT_NODES[1]}\", \"${BOOT_NODES[2]}\", \"${BOOT_NODES[3]}\", \"${BOOT_NODES[4]}\", \"${BOOT_NODES[5]}\"]|
s|^\s*#\s*miner_key\s*=.*|miner_key = \"$PRIVATE_KEY\"|
s|^\s*#\s*listen_address\s*=.*|listen_address = \"0.0.0.0:5678\"|
s|^\s*#\s*listen_address_admin\s*=.*|listen_address_admin = \"127.0.0.1:5679\"|
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = 326165|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = \"$BLOCKCHAIN_RPC_ENDPOINT\"|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = \"0xbD75117F80b4E22698D0Cd7612d92BDb8eaff628\"|
s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = \"0x3A0d1d67497Ad770d6f72e7f4B8F0BAbaa2A649C\"|
s|^\s*#\?\s*reward_contract_address\s*=.*|reward_contract_address = \"0xd3D4D91125D76112AE256327410Dd0414Ee08Cb4\"|
" $HOME/0g-storage-node/run/config-testnet.toml

# 9. Create service
sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config-testnet.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 10. Start the node
sudo systemctl daemon-reload && \
sudo systemctl enable zgs && \
sudo systemctl restart zgs

# 11. Show logs by date
echo "Full logs command: tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)"

# 12. Confirmation message for installation completion
if systemctl is-active --quiet zgs; then
    echo "Storage Node installation and services started successfully!"
else
    echo "Storage Node installation failed. Please check the logs for more information."
fi

echo "Let's Buidl 0G Together"
