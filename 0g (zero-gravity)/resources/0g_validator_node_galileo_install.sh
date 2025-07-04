#!/bin/bash

set -e

# ==== CONFIG ====
echo -e "\n--- 0G Validator Node Setup ---"

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Prompt for MONIKER, OG_PORT, and Indexer option
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number: (leave empty to use default: 26)" OG_PORT
if [ -z "$OG_PORT" ]; then
    OG_PORT=26
fi
read -p "Do you want to enable the indexer? (yes/no): " ENABLE_INDEXER

# Save env vars
echo "export MONIKER=\"$MONIKER\"" >> ~/.bash_profile
echo "export OG_PORT=\"$OG_PORT\"" >> ~/.bash_profile
echo 'export PATH=$PATH:$HOME/galileo/bin' >> ~/.bash_profile
source ~/.bash_profile

# CLEANUP EXISTING INSTALLATION
echo -e "\n\U0001F9F9 Cleaning up any existing 0G validator installation..."

sudo systemctl stop 0gchaind 2>/dev/null || true
sudo systemctl stop 0g-geth 0ggeth 2>/dev/null || true
sudo systemctl disable 0gchaind 2>/dev/null || true
sudo systemctl disable 0g-geth 0ggeth 2>/dev/null || true
sudo rm -f /etc/systemd/system/0gchaind.service /etc/systemd/system/0g-geth.service /etc/systemd/system/0ggeth.service
sudo rm -f $HOME/go/bin/0gchaind $HOME/go/bin/0g-geth $HOME/go/bin/0ggeth
rm -rf $HOME/.0gchaind $HOME/galileo $HOME/galileo-v1.2.0 $HOME/galileo-v1.2.0.tar.gz

echo "✅ Cleanup complete."

# ==== DEPENDENCIES ====
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

# ==== INSTALL GO ====
cd $HOME && ver="1.22.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
source ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
go version

# ==== DOWNLOAD GALILEO ====
cd $HOME
rm -rf galileo
wget https://github.com/0glabs/0gchain-NG/releases/download/v1.2.0/galileo-v1.2.0.tar.gz
tar -xzvf galileo-v1.2.0.tar.gz
mv galileo-v1.2.0 galileo
rm galileo-v1.2.0.tar.gz
sudo chmod +x $HOME/galileo/bin/geth
sudo chmod +x $HOME/galileo/bin/0gchaind

# ==== MOVE BINARIES ====
cp $HOME/galileo/bin/geth $HOME/go/bin/0g-geth
cp $HOME/galileo/bin/0gchaind $HOME/go/bin/0gchaind

# ==== INIT CHAIN ====
mkdir -p $HOME/.0gchaind/
cp -r $HOME/galileo/* $HOME/.0gchaind/
0g-geth init --datadir $HOME/.0gchaind/0g-home/geth-home $HOME/.0gchaind/genesis.json
0gchaind init $MONIKER --home $HOME/.0gchaind/tmp

# ==== COPY KEYS ====
cp $HOME/.0gchaind/tmp/data/priv_validator_state.json $HOME/.0gchaind/0g-home/0gchaind-home/data/
cp $HOME/.0gchaind/tmp/config/node_key.json $HOME/.0gchaind/0g-home/0gchaind-home/config/
cp $HOME/.0gchaind/tmp/config/priv_validator_key.json $HOME/.0gchaind/0g-home/0gchaind-home/config/

# ==== CONFIG PATCH ====
CONFIG="$HOME/.0gchaind/0g-home/0gchaind-home/config"
GCONFIG="$HOME/.0gchaind/geth-config.toml"

# config.toml
sed -i "s/^moniker *=.*/moniker = \"$MONIKER\"/" $CONFIG/config.toml
sed -i "s|laddr = \"tcp://0.0.0.0:26656\"|laddr = \"tcp://0.0.0.0:${OG_PORT}656\"|" $CONFIG/config.toml
sed -i "s|laddr = \"tcp://127.0.0.1:26657\"|laddr = \"tcp://127.0.0.1:${OG_PORT}657\"|" $CONFIG/config.toml
sed -i "s|^proxy_app = .*|proxy_app = \"tcp://127.0.0.1:${OG_PORT}658\"|" $CONFIG/config.toml
sed -i "s|^pprof_laddr = .*|pprof_laddr = \"0.0.0.0:${OG_PORT}060\"|" $CONFIG/config.toml
sed -i "s|prometheus_listen_addr = \".*\"|prometheus_listen_addr = \"0.0.0.0:${OG_PORT}660\"|" $CONFIG/config.toml

# Configure indexer based on user input
if [ "$ENABLE_INDEXER" = "yes" ]; then
    sed -i -e 's/^indexer = "null"/indexer = "kv"/' $CONFIG/config.toml
    echo "Indexer enabled."
else
    sed -i -e 's/^indexer = "kv"/indexer = "null"/' $CONFIG/config.toml
    echo "Indexer disabled."
fi

# app.toml
sed -i "s|address = \".*:3500\"|address = \"127.0.0.1:${OG_PORT}500\"|" $CONFIG/app.toml
sed -i "s|^rpc-dial-url *=.*|rpc-dial-url = \"http://localhost:${OG_PORT}551\"|" $CONFIG/app.toml
sed -i "s/^pruning *=.*/pruning = \"custom\"/" $CONFIG/app.toml
sed -i "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $CONFIG/app.toml
sed -i "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $CONFIG/app.toml

# geth-config.toml
sed -i "s/HTTPPort = .*/HTTPPort = ${OG_PORT}545/" $GCONFIG
sed -i "s/WSPort = .*/WSPort = ${OG_PORT}546/" $GCONFIG
sed -i "s/AuthPort = .*/AuthPort = ${OG_PORT}551/" $GCONFIG
sed -i "s/ListenAddr = .*/ListenAddr = \":${OG_PORT}303\"/" $GCONFIG
sed -i "s/^# *Port = .*/# Port = ${OG_PORT}901/" $GCONFIG
sed -i "s/^# *InfluxDBEndpoint = .*/# InfluxDBEndpoint = \"http:\/\/localhost:${OG_PORT}086\"/" $GCONFIG

# ==== SYSTEMD SERVICES ====
# 0gchaind.service
sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0gchaind Node Service
After=network-online.target

[Service]
User=$USER
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/.0gchaind
ExecStart=$HOME/go/bin/0gchaind start \
  --chaincfg.chain-spec devnet \
  --home $HOME/.0gchaind/0g-home/0gchaind-home \
  --chaincfg.kzg.trusted-setup-path=$HOME/.0gchaind/kzg-trusted-setup.json \
  --chaincfg.engine.jwt-secret-path=$HOME/.0gchaind/jwt-secret.hex \
  --chaincfg.kzg.implementation=crate-crypto/go-kzg-4844 \
  --chaincfg.engine.rpc-dial-url=http://localhost:${OG_PORT}551 \
  --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656 \
  --p2p.external_address=$(curl -4 -s ifconfig.me):${OG_PORT}656
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# geth.service
sudo tee /etc/systemd/system/0g-geth.service > /dev/null <<EOF
[Unit]
Description=0g Geth Node Service
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.0gchaind
ExecStart=$HOME/go/bin/0g-geth \
  --config $HOME/.0gchaind/geth-config.toml \
  --datadir $HOME/.0gchaind/0g-home/geth-home \
  --http.port ${OG_PORT}545 \
  --ws.port ${OG_PORT}546 \
  --authrpc.port ${OG_PORT}551 \
  --bootnodes enode://de7b86d8ac452b1413983049c20eafa2ea0851a3219c2cc12649b971c1677bd83fe24c5331e078471e52a94d95e8cde84cb9d866574fec957124e57ac6056699@8.218.88.60:30303 \
  --port ${OG_PORT}303 \
  --networkid 16601
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# ==== START SERVICES ====
sudo systemctl daemon-reload
sudo systemctl enable 0gchaind
sudo systemctl enable 0g-geth
sudo systemctl start 0gchaind
sudo systemctl start 0g-geth

# ==== DONE ====
echo -e "\n${GREEN}✅ 0G Validator Node Installation Completed Successfully!${RESET}"
echo -e "\n${YELLOW}Node Configuration Summary:${RESET}"
echo -e "Moniker: ${CYAN}$MONIKER${RESET}"
echo -e "Port Prefix: ${CYAN}$OG_PORT${RESET}"
echo -e "Indexer: ${CYAN}$([ "$ENABLE_INDEXER" = "yes" ] && echo "Enabled" || echo "Disabled")${RESET}"
echo -e "Node ID: ${CYAN}$(0gchaind comet show-node-id --home $HOME/.0gchaind/0g-home/0gchaind-home/)${RESET}"
echo -e "\n${YELLOW}Press Enter to continue to main menu...${RESET}"
read -r
