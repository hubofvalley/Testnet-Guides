#!/bin/bash

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Prompt for MONIKER, STORY_PORT, and Indexer option
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number: " STORY_PORT
read -p "Do you want to enable the indexer? (yes/no): " ENABLE_INDEXER

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

# 3. Install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

# 4. Set environment variables
echo "export MONIKER=\"$MONIKER\"" >> $HOME/.bash_profile
echo "export STORY_CHAIN_ID=\"odyssey\"" >> $HOME/.bash_profile
echo "export STORY_PORT=\"$STORY_PORT\"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# 5. Download Geth and Consensus Client binaries
cd $HOME

# Geth binary
mkdir -p story-geth-v0.10.0
wget -O story-geth-v0.10.0/geth-linux-amd64 https://github.com/piplabs/story-geth/releases/download/v0.10.0/geth-linux-amd64
story_file__name=geth-linux-amd64
cp story-geth-v0.10.0/$story_file__name $HOME/go/bin/geth
sudo chown -R $USER:$USER $HOME/go/bin/geth
sudo chmod +x $HOME/go/bin/geth

# Consensus client binary
mkdir -p story-v0.12.0
wget -O story-v0.12.0/story-linux-amd64 https://github.com/piplabs/story/releases/download/v0.12.0/story-linux-amd64
story_file__name=story-linux-amd64
cp story-v0.12.0/$story_file__name $HOME/go/bin/story
sudo chown -R $USER:$USER $HOME/go/bin/story
sudo chmod +x $HOME/go/bin/story

# 6. Initialize the app
story init --network $STORY_CHAIN_ID --moniker $MONIKER

# 7. Set custom ports in config.toml
sed -i.bak -e "/^\[p2p\]/,/^$/ s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${STORY_PORT}656\"%g;
s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${STORY_PORT}660\"%g;
s%proxy_app = \"tcp://127.0.0.1:29658\"%proxy_app = \"tcp://127.0.0.1:${STORY_PORT}658\"%g;
s%^laddr = \"tcp://127.0.0.1:29657\"%laddr = \"tcp://0.0.0.0:${STORY_PORT}657\"%g" $HOME/.story/story/config/config.toml

# 8. Add peers to the config.toml
peers=$(curl -sS https://lightnode-rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
echo $peers

# 9. Enable or disable indexer based on user input
if [ "$ENABLE_INDEXER" = "yes" ]; then
    sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.story/story/config/config.toml
    echo "Indexer enabled."
else
    sed -i -e 's/^indexer = "kv"/indexer = "null"/' $HOME/.story/story/config/config.toml
    echo "Indexer disabled."
fi

# 10. Export Private key
story validator export --evm-key-path $HOME/.story/story/config/private_key.txt --export-evm-key
PRIVATE_KEY=$(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt)

# 11. Initialize Cosmovisor
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name "story")" >> $HOME/.bash_profile
source $HOME/.bash_profile
cosmovisor init $HOME/go/bin/story
mkdir -p $HOME/.story/story/cosmovisor/upgrades
mkdir -p $HOME/.story/story/cosmovisor/backup

# 12. Define Cosmovisor paths for the consensus client
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$input3" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "Cosmovisor path: $input1"
echo "Story home: $input2"
echo "Backup directory: $input3"

# 13. Create systemd service files for the consensus and Geth clients

# Consensus service file
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor Story Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.story/story
ExecStart=$input1 run run
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=story"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Geth service file
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --odyssey --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 0.0.0.0 --http.port 8545 --ws --ws.api eth,web3,net,txpool --ws.addr 0.0.0.0 --ws.port 8546
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 14. Start the node
sudo systemctl daemon-reload
sudo systemctl enable story-geth story
sudo systemctl restart story-geth story

# 14. Confirmation message for installation completion
if systemctl is-active --quiet story && systemctl is-active --quiet story-geth; then
    echo "Node installation and services started successfully!"
else
    echo "Node installation failed. Please check the logs for more information."
fi

# show the full logs
echo "sudo journalctl -u story-geth -u story -fn 100"
