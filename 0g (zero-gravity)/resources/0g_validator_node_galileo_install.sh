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
sudo systemctl stop 0gchaind 0g-geth 0ggeth
sudo systemctl disable 0gchaind 0g-geth 0ggeth
sudo rm -rf /etc/systemd/system/0gchaind.service /etc/systemd/system/0g-geth.service /etc/systemd/system/0ggeth.service
sudo rm -rf $HOME/galileo $HOME/.0gchaind $HOME/.bash_profile
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
wget https://github.com/0glabs/0gchain-NG/releases/download/v1.2.0/galileo-v1.2.0.tar.gz
tar -xzvf galileo-v1.2.0.tar.gz -C $HOME
cd galileo
cp -r 0g-home/* $HOME/galileo/0g-home/
sudo chmod 777 ./bin/geth ./bin/0gchaind

# Put consensus client and execution client (geth) binaries into go directory
cp $HOME/galileo/bin/geth $HOME/go/bin/0g-geth
cp $HOME/galileo/bin/0gchaind $HOME/go/bin/0gchaind
sudo chmod 777 $HOME/go/bin/0g-geth $HOME/go/bin/0gchaind

# check consensus client and execution client (geth) version
source $HOME/.bash_profile
0gchaind version
0g-geth version

# create .0gchaind directory and put 0g-home directory inside it
mkdir -p $HOME/.0gchaind
cp -r $HOME/galileo/0g-home $HOME/.0gchaind

# Init
0g-geth init --datadir $HOME/galileo/0g-home/geth-home $HOME/galileo/genesis.json
0gchaind init "$MONIKER" --home $HOME/.0gchaind/tmp

# Patch configs in tmp and in final 0gchaind-home/config
for CONFIG_DIR in "$HOME/.0gchaind/tmp/config" "$HOME/.0gchaind/0g-home/0gchaind-home/config"
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
for CONFIG_DIR in "$HOME/.0gchaind/tmp/config" "$HOME/.0gchaind/0g-home/0gchaind-home/config"
do
  sed -i.bak "s|^node = \".*\"|node = \"tcp://localhost:${OG_PORT}657\"|" "${CONFIG_DIR}/client.toml"

  # Change the moniker in `config.toml` to `$MONIKER`.
  sed -i.bak "s|^moniker = \".*\"|moniker = \"${MONIKER}\"|" "${CONFIG_DIR}/config.toml"
done

# Add peers to the config.toml
for CONFIG_DIR in "$HOME/.0gchaind/tmp/config" "$HOME/.0gchaind/0g-home/0gchaind-home/config"
do
  peers=$(curl -sS https://lightnode-rpc-0g.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
  echo $peers
  sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"a97c8615903e795135066842e5739e30d64e2342@peer-0g.grandvalleys.com:28656,$peers\"|" ${CONFIG_DIR}/config.toml
done

# Copy node files
cp $HOME/.0gchaind/tmp/data/priv_validator_state.json $HOME/.0gchaind/0g-home/0gchaind-home/data/
cp $HOME/.0gchaind/tmp/config/node_key.json $HOME/.0gchaind/0g-home/0gchaind-home/config/
cp $HOME/.0gchaind/tmp/config/priv_validator_key.json $HOME/.0gchaind/0g-home/0gchaind-home/config/

# Export PATH
echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bash_profile
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
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/galileo
ExecStart=$HOME/go/bin/0gchaind start \
    --chain-spec devnet \
    --rpc.laddr tcp://0.0.0.0:${OG_PORT}657 \
    --kzg.trusted-setup-path=$HOME/galileo/kzg-trusted-setup.json \
    --engine.jwt-secret-path=$HOME/galileo/jwt-secret.hex \
    --kzg.implementation=crate-crypto/go-kzg-4844 \
    --block-store-service.enabled \
    --node-api.enabled \
    --node-api.logging \
    --node-api.address 0.0.0.0:${OG_PORT}500 \
    --pruning=nothing \
    --home $HOME/.0gchaind/0g-home/0gchaind-home \
    --p2p.external_address $SERVER_IP:${OG_PORT}656 \
    --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Create 0g-geth systemd service
sudo tee /etc/systemd/system/0g-geth.service > /dev/null <<EOF
[Unit]
Description=0g Geth Node Service
After=network-online.target
Wants=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/0g-geth --config $HOME/galileo/geth-config.toml --datadir $HOME/.0gchaind/0g-home/geth-home --networkid 16601 --port ${OG_PORT}303 --http.port ${OG_PORT}545 --ws.port ${OG_PORT}546 --authrpc.port ${OG_PORT}551 --bootnodes enode://de7b86d8ac452b1413983049c20eafa2ea0851a3219c2cc12649b971c1677bd83fe24c5331e078471e52a94d95e8cde84cb9d866574fec957124e57ac6056699@8.218.88.60:30303
Restart=always
WorkingDirectory=$HOME/galileo
RestartSec=3
LimitNOFILE=65535

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
