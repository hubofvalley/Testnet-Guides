#!/bin/bash

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Prompt for MONIKER, NAMADA_PORT, and Indexer option
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number: (leave empty to use default: 26)" NAMADA_PORT
if [ -z "$NAMADA_PORT" ]; then
    NAMADA_PORT=26
fi
read -p "Enter your wallet name: " WALLET_NAME
read -p "Do you want to enable the indexer? (y/n): " ENABLE_INDEXER
read -p "Do you want to join the network as a pre-genesis validator? (y/n): " PRE_GENESIS

if [ "$PRE_GENESIS" = "y" ]; then
    read -p "Have you already put the validator-wallet.toml file into your pre-genesis directory ($HOME/.local/share/bin/namada/pre-genesis/youralias/validator-wallet.toml) ? (y/n): " VALIDATOR_FILE_PLACED
    if [ "$VALIDATOR_FILE_PLACED" != "y" ]; then
        echo "Please place the validator-wallet.toml file into your pre-genesis directory ($HOME/.local/share/bin/namada/pre-genesis/youralias/) and run the script again."
        exit 1
    fi
    read -p "Enter your validator alias: " VALIDATOR_ALIAS
fi

# Stop and remove existing Namada node
sudo systemctl daemon-reload
sudo systemctl stop namadad
sudo systemctl disable namadad
sudo rm -rf /etc/systemd/system/namadad.service
sudo rm /usr/local/bin/namad*
sudo rm -r namada
sudo rm -rf $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac
sed -i "/NAMADA_/d" $HOME/.bash_profile

# 1. Install dependencies for building from source
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# 2. Install Go
cd $HOME && ver="1.22.0"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
source ~/.bash_profile
go version

# 3. install rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustc --version

# 4. install cometbft

cd $HOME
rm -rf cometbft
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout v0.37.11
make build
sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/
cometbft version

# 5. Set environment variables
echo 'export MONIKER="$MONIKER"' >> $HOME/.bash_profile
echo 'export WALLET_NAME="$WALLET_NAME"' >> $HOME/.bash_profile
echo 'export NAMADA_CHAIN_ID="campfire-square.ff09671d333707"' >> $HOME/.bash_profile
echo 'export NAMADA_PORT="$NAMADA_PORT"' >> $HOME/.bash_profile
echo 'export BASE_DIR="$HOME/.local/share/namada"' >> $HOME/.bash_profile
echo 'export NAMADA_NETWORK_CONFIGS_SERVER="https://testnet.campfire.tududes.com/configs"' >> $HOME/.bash_profile
export NAMADA_CHAIN_ID="campfire-square.ff09671d333707"
source $HOME/.bash_profile

# 6. Download Namada binaries
cd $HOME
wget https://github.com/anoma/namada/releases/download/v1.0.0/namada-v1.0.0-Linux-x86_64.tar.gz
tar -xvf namada-v1.0.0-Linux-x86_64.tar.gz
cd namada-v1.0.0-Linux-x86_64
sudo mv namad* /usr/local/bin/

# 7. Initialize the app
if [ "$PRE_GENESIS" = "y" ]; then
    namadac utils join-network --chain-id $NAMADA_CHAIN_ID --genesis-validator $VALIDATOR_ALIAS
else
    namadac utils join-network --chain-id $NAMADA_CHAIN_ID
fi

peers="tcp://e9a6dafe9a6d8e2e61b7ae70607aa2859eacd0a1@206.168.190.35:26656"0
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/campfire-square.ff09671d333707/config.toml

# 8. Set custom ports and moniker in config.toml
sed -i.bak -e "s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NAMADA_PORT}656\"%g;
s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NAMADA_PORT}660\"%g;
s%moniker = \""technodrome"\"%moniker = \""$MONIKER"\"%g;
s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NAMADA_PORT}658\"%g;
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NAMADA_PORT}657\"%g;
s%^oracle_rpc_endpoint = \"http://127.0.0.1:8545\"%oracle_rpc_endpoint = \"http://127.0.0.1:${NAMADA_PORT}545\"%g;
s%^pprof_laddr = \"localhost:26060\"%pprof_laddr = \"localhost:${NAMADA_PORT}060\"%g" $HOME/.local/share/namada/campfire-square.ff09671d333707/config.toml

# 9. Enable or disable indexer based on user input
if [ "$ENABLE_INDEXER" = "y" ]; then
    sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.local/share/namada/campfire-square.ff09671d333707/config.toml
    echo "Indexer enabled."
else
    sed -i -e 's/^indexer = "kv"/indexer = "null"/' $HOME/.local/share/namada/campfire-square.ff09671d333707/config.toml
    echo "Indexer disabled."
fi

# 10. Create systemd service files for the namada validator node

# Consensus service file
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=Namada Campfire Testnet Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=CMT_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namadan ledger run
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 11. Start the node
sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl restart namadad

# 12. Confirmation message for installation completion
if systemctl is-active --quiet namadad; then
    echo "Node installation and services started successfully!"
else
    echo "Node installation failed. Please check the logs for more information."
fi

# show the full logs
echo "sudo journalctl -u namadad -fn 100"
