#!/bin/bash

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Stop and remove existing 0G node
sudo systemctl daemon-reload
sudo systemctl stop 0gchaind 0gd
sudo systemctl disable 0gchaind
sudo systemctl disable 0gd
sudo rm -rf /etc/systemd/system/0gchaind.service
sudo rm -rf /etc/systemd/system/0gd.service
sudo rm -r 0g-chain
sudo rm -rf $HOME/.0gchain
sed -i "/OG_/d" $HOME/.bash_profile

# Prompt user for moniker and port number
read -p "Enter your moniker: " MONIKER
read -p "Enter your custom port number (leave empty to use default: 26): " OG_PORT
if [ -z "$OG_PORT" ]; then
    OG_PORT=26
fi
read -p "Enter your wallet name: " WALLET

# 1. Install dependencies for building from source
sudo apt update -y && sudo apt upgrade -y && \
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl \
libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# 2. install go
cd $HOME && ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile && \
source ~/.bash_profile && go version

# 3. install cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

# 4. set vars
echo "export WALLET="$WALLET"" >> $HOME/.bash_profile
echo "export MONIKER="$MONIKER"" >> $HOME/.bash_profile
echo "export OG_CHAIN_ID="zgtendermint_16600-2"" >> $HOME/.bash_profile
echo "export OG_PORT="$OG_PORT"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# 5. download binary
git clone -b v0.2.5 https://github.com/0glabs/0g-chain.git
cd 0g-chain
make install
0gchaind version

# 6. config and init app
cd $HOME
0gchaind init $MONIKER --chain-id $OG_CHAIN_ID
0gchaind config chain-id $OG_CHAIN_ID
0gchaind config node tcp://localhost:${OG_PORT}657
0gchaind config keyring-backend os

# 7. set custom ports in config.toml file
sed -i.bak -e "/^\[p2p\]/,/^$/ s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${0G_PORT}656\"%g;
s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${0G_PORT}660\"%g;
s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OG_PORT}658\"%g;
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${0G_PORT}657\"%g;
s%^pprof_laddr = \"localhost:26060\"%pprof_laddr = \"localhost:${0G_PORT}060\"%g" $HOME/.0gchain/config/config.toml

# 8. download genesis.json
sudo rm $HOME/.0gchain/config/genesis.json && \
wget https://github.com/0glabs/0g-chain/releases/download/v0.2.3/genesis.json -O $HOME/.0gchain/config/genesis.json

# 9. add seeds to the config.toml
SEEDS="81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656,8f21742ea5487da6e0697ba7d7b36961d3599567@og-testnet-seed.itrocket.net:47656" && \
sed -i.bak -e "s/^seeds *=.*/seeds = \"${SEEDS}\"/" $HOME/.0gchain/config/config.toml

# 10. add peers to the config.toml
peers=$(curl -sS https://lightnode-rpc-0g.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
echo $peers
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.0gchain/config/config.toml

# 11. configure pruning to save storage (optional) (if u want to run a full node, skip this step)
sed -i \
   -e "s/^pruning *=.*/pruning = \"custom\"/" \
   -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
   -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" \
   "$HOME/.0gchain/config/app.toml"

# 12. open rpc endpoints
sed -i \
   -e "s/laddr = \"tcp:\/\/127.0.0.1:${OG_PORT}657\"/laddr = \"tcp:\/\/0.0.0.0:${OG_PORT}657\"/" \
   $HOME/.0gchain/config/config.toml

# 13. open json-rpc endpoints (required for running the storage node and storage kv)
sed -i \
   -e 's/address = "127.0.0.1:8545"/address = "0.0.0.0:8545"/' \
   -e 's|^api = ".*"|api = "eth,txpool,personal,net,debug,web3"|' \
   -e 's/logs-cap = 10000/logs-cap = 20000/' \
   -e 's/block-range-cap = 10000/block-range-cap = 20000/' \
   $HOME/.0gchain/config/app.toml

# 14. open api endpoints
sed -i \
   -e '/^\[api\]/,/^\[/ s/^address = .*/address = "tcp:\/\/0.0.0.0:1317"/' \
   -e '/^\[api\]/,/^\[/ s/^enable = .*/enable = true/' \
   $HOME/.0gchain/config/app.toml

# 15. set minimum gas price and enable prometheus
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ua0gi\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchain/config/config.toml

# 16. disable indexer (optional) (if u want to run a full node, skip this step)
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchain/config/config.toml

# 17. initialize cosmovisor
echo "export DAEMON_NAME=0gchaind" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name ".0gchain")" >> $HOME/.bash_profile
source $HOME/.bash_profile
cosmovisor init $HOME/go/bin/0gchaind && \
mkdir -p $HOME/.0gchain/cosmovisor/upgrades && \
mkdir -p $HOME/.0gchain/cosmovisor/backup

# 18. define the path of cosmovisor
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name ".0gchain")
input3=$(find $HOME/.0gchain/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=0gchaind" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.0gchain/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "input1. $input1"
echo "input2. $input2"
echo "input3. $input3"

# 19. create service file
sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor 0G Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.0gchain
ExecStart=$input1 run start --log_output_console
StandardOutput=journal
StandardError=journal
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=0gchaind"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# 20. start the node
sudo systemctl daemon-reload && \
sudo systemctl enable 0gchaind && \
sudo systemctl restart 0gchaind

# 21. Confirmation message for installation completion
if systemctl is-active --quiet 0gchaind; then
    echo "Validator Node installation and services started successfully!"
else
    echo "Validator Node installation failed. Please check the logs for more information."
fi

# show the full logs
echo "run this to show the full logs: sudo journalctl -u 0gchaind -fn 100"

echo "Let's Buidl 0G Together"
