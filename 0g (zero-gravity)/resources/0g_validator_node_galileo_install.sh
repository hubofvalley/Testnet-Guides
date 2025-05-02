#!/bin/bash

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Prompt for MONIKER and custom port
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number (default: 26): " OG_PORT
if [ -z "$OG_PORT" ]; then
    OG_PORT=26
fi

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Cleanup
sudo systemctl stop 0gchaind 0g-geth
sudo systemctl disable 0gchaind 0g-geth
sudo rm -rf /etc/systemd/system/0gchaind.service /etc/systemd/system/0g-geth.service
rm -rf $HOME/galileo $HOME/.0gchaind $HOME/go/bin/* $HOME/.bash_profile
sudo rm /usr/local/bin/0gchaind

# Install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# Install Go
cd $HOME && ver="1.22.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

# Download and extract
cd $HOME
wget https://github.com/0glabs/0gchain-ng/releases/download/v1.0.1/galileo-v1.0.1.tar.gz
tar -xzvf galileo-v1.0.1.tar.gz -C $HOME
cd galileo
cp -r 0g-home/* $HOME/galileo/0g-home/
sudo chmod 777 ./bin/geth ./bin/0gchaind

# Init
./bin/geth init --datadir $HOME/galileo/0g-home/geth-home ./genesis.json
./bin/0gchaind init "$MONIKER" --home $HOME/galileo/tmp

# Patch configs in tmp and in final 0gchaind-home/config
for CONFIG_DIR in "$HOME/galileo/tmp/config" "$HOME/galileo/0g-home/0gchaind-home/config"
do
  sed -i.bak "
  s|tcp://0.0.0.0:26656|tcp://0.0.0.0:${OG_PORT}656|;
  s|tcp://127.0.0.1:26657|tcp://0.0.0.0:${OG_PORT}657|;
  s|tcp://127.0.0.1:26658|tcp://127.0.0.1:${OG_PORT}658|;
  s|0.0.0.0:6060|0.0.0.0:${OG_PORT}060|;
  s|0.0.0.0:26660|0.0.0.0:${OG_PORT}660|
  " "${CONFIG_DIR}/config.toml"

  sed -i.bak "
  s|127.0.0.1:1317|127.0.0.1:${OG_PORT}317|;
  s|127.0.0.1:8545|127.0.0.1:${OG_PORT}545|;
  s|127.0.0.1:8546|127.0.0.1:${OG_PORT}546|;
  s|http://localhost:8551|http://localhost:${OG_PORT}551|;
  s|127.0.0.1:3500|0.0.0.0:${OG_PORT}500|
  " "${CONFIG_DIR}/app.toml"
done

# Patch client.toml port in both config directories
for CONFIG_DIR in "$HOME/galileo/tmp/config" "$HOME/galileo/0g-home/0gchaind-home/config"
do
  sed -i.bak "s|^node = \".*\"|node = \"tcp://localhost:${OG_PORT}657\"|" "${CONFIG_DIR}/client.toml"
done

# Copy node files
cp $HOME/galileo/tmp/data/priv_validator_state.json $HOME/galileo/0g-home/0gchaind-home/data/
cp $HOME/galileo/tmp/config/node_key.json $HOME/galileo/0g-home/0gchaind-home/config/
cp $HOME/galileo/tmp/config/priv_validator_key.json $HOME/galileo/0g-home/0gchaind-home/config/

# Export PATH
echo 'export PATH=$PATH:$HOME/galileo/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile

# Update geth-config.toml ports based on OG_PORT
GETH_CONFIG="$HOME/galileo/geth-config.toml"
sed -i.bak "
s/^HTTPPort = .*/HTTPPort = ${OG_PORT}545/;
s/^WSPort = .*/WSPort = ${OG_PORT}546/;
s/^AuthPort = .*/AuthPort = ${OG_PORT}551/;
s/^ListenAddr = \":30303\"/ListenAddr = \":${OG_PORT}303\"/
" $GETH_CONFIG

# Create 0gchaind systemd service
sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0gchaind Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'cd ~/galileo && CHAIN_SPEC=devnet ./bin/0gchaind start \
    --rpc.laddr tcp://0.0.0.0:${OG_PORT}657 \
    --beacon-kit.kzg.trusted-setup-path=kzg-trusted-setup.json \
    --beacon-kit.engine.jwt-secret-path=jwt-secret.hex \
    --beacon-kit.kzg.implementation=crate-crypto/go-kzg-4844 \
    --beacon-kit.block-store-service.enabled \
    --beacon-kit.node-api.enabled \
    --beacon-kit.node-api.logging \
    --beacon-kit.node-api.address 0.0.0.0:${OG_PORT}500 \
    --pruning=nothing \
    --home $HOME/galileo/0g-home/0gchaind-home \
    --p2p.external_address $SERVER_IP:${OG_PORT}656 \
    --p2p.seeds b30fb241f3c5aee0839c0ea55bd7ca18e5c855c1@8.218.94.246:26656'
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Create 0g-geth systemd service
sudo tee /etc/systemd/system/0g-geth.service > /dev/null <<EOF
[Unit]
Description=0g Geth Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'cd ~/galileo && ./bin/geth --config geth-config.toml --datadir $HOME/galileo/0g-home/geth-home --networkid 80087'
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable 0g-geth.service
sudo systemctl start 0g-geth.service
sudo systemctl enable 0gchaind.service
sudo systemctl start 0gchaind.service

# Logs
echo "Check logs with: sudo journalctl -u 0gchaind -u 0g-geth -fn 100"
