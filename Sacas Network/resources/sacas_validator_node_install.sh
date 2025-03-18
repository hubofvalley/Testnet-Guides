#!/bin/bash

# Logo and introduction

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

echo "Welcome to the Sacas Network Validator Node Installation Script"
echo "This script will guide you through the process of setting up a Sacas Network validator node."
echo "Press Enter to continue..."
read -p ""

# Prompt for MONIKER, SACAS_PORT, and Indexer option
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number (leave empty to use default: 26): " SACAS_PORT
if [ -z "$SACAS_PORT" ]; then
    SACAS_PORT=26
fi
read -p "Enter your wallet name: " WALLET_NAME
read -p "Do you want to enable the indexer? (yes/no): " ENABLE_INDEXER

# Stop and remove existing Sacas node
sudo systemctl daemon-reload
sudo systemctl stop sacasd
sudo systemctl disable sacasd
sudo rm -rf /etc/systemd/system/sacasd.service
sudo rm -r sacas
sudo rm -rf $HOME/.sacasd
sed -i "/SACAS_/d" $HOME/.bash_profile

# 1. Install dependencies for building from source
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# 2. Install Go
cd $HOME && ver="1.22.0"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >>~/.bash_profile
source ~/.bash_profile
go version

# 3. Install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

# 4. Set environment variables
echo 'export MONIKER="$MONIKER"' >>$HOME/.bash_profile
echo 'export WALLET_NAME="$WALLET_NAME"' >>$HOME/.bash_profile
echo 'export SACAS_CHAIN_ID="sac_1317-1"' >>$HOME/.bash_profile
echo 'export SACAS_PORT="$SACAS_PORT"' >>$HOME/.bash_profile
source $HOME/.bash_profile

# 5. Download Sacas binaries
cd $HOME
git clone -b v0.20.0 https://github.com/sacasnetwork/sacas.git
cd sacas
make install
sacasd version

# 6. Initialize the app
cd $HOME
sacasd init $MONIKER --chain-id $SACAS_CHAIN_ID

# 7. set chain id and custom ports in client.toml file
sed -i.bak \
    -e "s/^chain-id = \"\"/chain-id = \"$SACAS_CHAIN_ID\"/" \
    -e "s%node = \"tcp://localhost:26657\"%node = \"tcp://localhost:${SACAS_PORT}657\"%" \
    "$HOME/.sacasd/config/client.toml"

# 8. Set custom ports in config.toml file
sed -i.bak -e "s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SACAS_PORT}656\"%;
s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SACAS_PORT}660\"%;
s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SACAS_PORT}658\"%;
s%laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${SACAS_PORT}657\"%;
s%^pprof_laddr = \"localhost:26060\"%pprof_laddr = \"localhost:${SACAS_PORT}060\"%" $HOME/.sacasd/config/config.toml

# 9. Set custom ports in app.toml file
sed -i.bak -e "s%address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SACAS_PORT}317\"%;
s%address = \"127.0.0.1:8545\"%address = \"127.0.0.1:${SACAS_PORT}545\"%;
s%ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:${SACAS_PORT}546\"%;
s%metrics-address = \"127.0.0.1:6065\"%metrics-address = \"127.0.0.1:${SACAS_PORT}065\"%" $HOME/.sacasd/config/app.toml

# 10. Add peers to the config.toml
peers=$(curl -sS https://lightnode-rpc-sacas.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
echo $peers
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.sacasd/config/config.toml

# 1. Configure pruning to save storage (optional) (if you want to run a full node, skip this step)
sed -i \
    -e "s/^pruning *=.*/pruning = \"custom\"/" \
    -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
    -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" \
    "$HOME/.sacasd/config/app.toml"

# 12. Open rpc endpoints
sed -i \
    -e "s/laddr = \"tcp:\/\/127.0.0.1:${SACAS_PORT}657\"/laddr = \"tcp:\/\/0.0.0.0:${SACAS_PORT}657\"/" \
    $HOME/.sacasd/config/config.toml

# 13. Open json-rpc endpoints (required for running the storage node and storage kv)
sed -i \
    -e 's/address = "127.0.0.1:${SACAS_PORT}545"/address = "0.0.0.0:${SACAS_PORT}545"/' \
    -e 's|^api = ".*"|api = "eth,txpool,personal,net,debug,web3"|' \
    -e 's/logs-cap = 10000/logs-cap = 20000/' \
    -e 's/block-range-cap = 10000/block-range-cap = 20000/' \
    $HOME/.sacasd/config/app.toml

# 14. Open api endpoints
sed -i \
    -e '/^\[api\]/,/^\[/ s/^enable = .*/enable = true/' \
    $HOME/.sacasd/config/app.toml

# 15. Set minimum gas price and enable prometheus
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0asacas\"/" $HOME/.sacasd/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sacasd/config/config.toml

# 16. Disable indexer (optional) (if you want to run a full node, skip this step)
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.sacasd/config/config.toml

# 17. Initialize Cosmovisor
echo "export DAEMON_NAME=sacasd" >>$HOME/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name ".sacasd" -print -quit)" >>$HOME/.bash_profile
source $HOME/.bash_profile
cosmovisor init $HOME/go/bin/sacasd
cd $HOME/go/bin/
sudo rm -r $HOME/go/bin/sacasd
ln -s $HOME/.sacasd/cosmovisor/current/bin/sacasd sacasd
sudo chown -R $USER:$USER $HOME/go/bin/sacasd
sudo chmod +x $HOME/go/bin/sacasd
mkdir -p $HOME/.sacasd/cosmovisor/upgrades
mkdir -p $HOME/.sacasd/cosmovisor/backup
cd $HOME

# 18. Define the path of Cosmovisor
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name ".sacasd")
input3=$(find $HOME/.sacasd/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=sacasd" >>$HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >>$HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.sacasd/cosmovisor -type d -name "backup")" >>$HOME/.bash_profile
source $HOME/.bash_profile
echo "input1. $input1"
echo "input2. $input2"
echo "input3. $input3"

# 19. Create systemd service files for the Sacas validator node
sudo tee /etc/systemd/system/sacasd.service >/dev/null <<EOF
[Unit]
Description=Cosmovisor Sacas Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.sacasd
ExecStart=$input1 run start
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=sacasd"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# 20. Start the node
sudo systemctl daemon-reload
sudo systemctl enable sacasd
sudo systemctl restart sacasd

# 21. Confirmation message for installation completion
if systemctl is-active --quiet sacasd; then
    echo "Node installation and services started successfully!"
else
    echo "Node installation failed. Please check the logs for more information."
fi

# Show the full logs
echo "sudo journalctl -u sacasd -fn 100"
